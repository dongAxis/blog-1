<!--
{
  "title": "content_shell overview (from Chromium)",
  "date": "2017-02-22T05:29:15.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# content_shell

```
# build
$ ninja -C out/Default content/shell:content_shell

# run
$ out/Default/content_shell <url>

# layout test (see docs/testing/layout_tests.md)
$ out/Default/content_shell --run-layout-test third_party/WebKit/LayoutTests/css2.1/20110323/abspos-containing-block-initial-001.htm
...(output layout calculation as plain text to stdout)...
layer at (0,0) size 800x600 clip at (0,0) size 785x600 scrollY 50.00 scrollHeight 10120
  LayoutView at (0,0) size 800x600
...

# debug browser process (for some reason, sometimes, browser process's UI thread locks on some spin lock (base::Internal::SpinLockDelay) when I do step execution.)
$ lldb out/Default/content_shell
(lldb) breakpoint set --name main
(lldb) process launch
(lldb) gui
...

## debug renderer process (https://www.chromium.org/blink/getting-started-with-blink-debugging) ##
# from one shell
$ out/Default/content_shell --no-sandbox --disable-hang-monitor --renderer-startup-dialog

# from another shell
$ lldb -p $(pgrep -f 'content_shell --type=renderer')
(lldb) gui # set one-time breakpoint somewhere after the current pause()
(lldb) c
(lldb) pr signal SIGUSR1
(lldb) c
(lldb) gui
```

- entrypoint (cd content/shell)
  - Build.gn (executable("content_shell"))
  - app/shell_main.cc

```
- Browser process (read browser_main_loop.h well)
  - main => content::ContentMain =>
    - ContentMainRunner::Initialize =>
      - ShellMainDelegate::BasicStartupComplete
      - InitializeMojo
    - ContentMainRunner::Run => RunNamedProcessTypeMain => ShellMainDelegate::RunProcess => ShellBrowserMain =>
    - BrowserMainRunner::Initialize =>
      - SkGraphics::Init
      - BrowserMainLoop::Init => ShellContentBrowserClient::CreateBrowserMainParts => new ShellBrowserMainParts
      - BrowserMainLoop::EarlyInitialization =>
        - SetupSandbox =>
          - RenderSandboxLinux::Init =>
            - new base::DelegateSimpleThread(...SandboxIPCHandler...)
            - SimpleThread::Start => PlatformThread::CreateWithPriority => CreateThread => pthread_create(..., ThreadFunc, ...) => ThreadFunc => SimpleThread::ThreadMain (override PlatformThread::Delegate::ThreadMain) =>
              - WaitableEvent::Signal (will catched WaitableEvent::wait in later part of SimpleThread::Start)
              - DelegateSimpleThread::Run => SandboxIPCHandler::Run/HandleRequestFromRenderer (see linux_sandbox_ipc.md for this thread loop)
          - ZygoteHostImpl::Init
          - CreateZygote => ZygoteCommunication::Init => ZygoteHostImpl::LaunchZygote => sandbox::NamespaceSandbox::LaunchProcess
            - ?? => +1 thread
      - BrowserMainLoop::InitializeToolkit
        - aura::Env::CreateInstance, aura::Env::Init => ui::PlatformEventSource::CreateDefault => gfx::GetXDisplay
      - BrowserMainLoop::MainMessageLoopStart =>
        - new base::MessageLoopForUI
        - InitializaMainThread => new BrowserThreadImpl(BrowserThread::UI, base::MessageLoop::current())
      - BrowserMainLoop::PostMessageLoopStart => ?? +4 threads
      - BrowserMainLoop::CreateStartupTasks (4 tasks) => RunAllTasksNow =>
        - PreCreateThreads => ?? +2 threads
        - CreateThreads =>
          - base::TaskScheduler::CreateAndSetDefaultTaskScheduler => +5 threads
          - => BrowserProcessSubThreads (db, file_user_blocking, file, process_launcher, cache, io) +6 threads
        - BrowserThreadsStarted =>
          - InitializeMojo (isn't it a second time ?)
          - indexed_db_thread_->Start() => +1 thread
          - BrowserGpuChannelHostFactory::Initialize
          - ImageTransportFactory::Initialize => +1 thread
          - CreateAudioManager => +2 threads
        - PreMainMessageLoopRun =>
          - ShellBrowserMainParts::PreMainMessageLoopStart =>
            - InitializeBrowserContexts => BrowserContext::Initialize
            - content::Shell::Initialize => content::Shell::PlatformInitialize (content/shell/browser/shell_views.cc) =>
              - new wm::WMState
              - views::CreateDesktopScreen => new DesktopScreenX11 => PlatformEventSource::AddPlatformEventDispatcher(this)
              - => +1 thread around here (maybe one-off thread for some small task) ??
            - ShellDevToolsManagerDelegate::StartHttpHandler => DevToolsAgentHost::StartRemoteDebuggingServer => new DevToolsHttpHandler ...
            - InitializeMessageLoopContext => Shell::CreateNewWindow =>
              - content::WebContents::CreateParams
              - WebContents::Create => ... => WebContentsImpl::Init
                - (create SiteInstance)
                - (create RenderWidgetHost/RenderViewHost/RenderFrameHost)
                - (new WebContentsViewAura and WebContentsViewAura::CreateView)
              - Shell::CreateShell =>
                - new Shell
                - Shell::CreatePlatformWindow =>
                  - window_widget_ = new views::Widget
                  - Widget::Init =>
                    - DesktopTestViewsDelegate::onBeforeWidgetInit => new DesktopNativeWidgetAura => new aura::Window
                    - CreateRootView
                    - DesktopNativeWidgetAura::InitNativeWidget =>
                      - aura::Window::Init (for content_window)
                      - aura::Window::Window/Init/Show (for content_window_container)
                      - content_window_container->AddChild(content_window)
                      - DesktopWindowTreeHost::Create => new DesktopWindowTreeHostX11 => ...
                      - DesktopWindowTreeHostX11::Init =>
                        - DesktopWindowTreeHostX11::InitX11Window =>
                          - XCreateWindow
                          - PlatformEventSource::AddPlatformEventDispatcher(this)
                        - aura::WindowTreeHost::InitHost => ...
                - WindowTreeHost::Show =>
                  - DesktopWindowHostTreeX11::ShowImpl =>
                    - ShowWindowWithState (this actually create window on my PC)
                    - aura::Window::Show
                - Shell::PlatformSetContents =>
                  - ShellWindowDelegateView::SetWebContents =>
                    - new views::WebView
                    - views::WebView::SetWebContents
                    - views::View::Layout
              - Shell::LoadURL (with GURL "https://www.google.com/") => LoadURLForFrame =>
                - NavigationControllerImpl::LoadURLWithParams =>
                  - CreateNavigationEntry
                  - LoadEntry => NavigateToPendingEntry => NavigateToPendingEntryInterval =>
                    NavigatorImpl::NavigateToPendingEntry/NavigateToEntry =>
                    RenderFrameHostManager::Navigate/ReinitializeRenderFrame/InitRenderView => ... =>
                    RenderProcessHostImpl::Init (supposed to spawn renderer via zygote)
                  - RenderFrameHostManager::InitRenderView => WebContentsImpl::CreateRenderViewForRenderManager =>
                    RenderViewHostImpl::CreateRenderView =>
                    content::mojom::RendererProxy::CreateView (content/common/renderer.mojom) =>
                    ::content::mojom::internal::Renderer_CreateView_Params_Data::New (TODO: follow renderer's reaction)
                - WebContentsImpl::Focus => ... => RenderWidgetHostViewAura::Focus => ... =>
                  wm::FocusController::FocusAndActivateWIndow => ... => RenderProcessHostImpl::Send(new ViewMsg_SetActive)
    - BrowserMainRunner::Run =>
      - BrowserMainLoop::RunMainMessageLoopParts => MainMessageLoopRun => base::RunLoop::Run (see below for main loop flow)
        - g_main_context_iteration =>
          - when this line passed, my ubuntu's dock icon is highlighted, why ??
          - when try to step in, segmentation fault happens !?
        - MessageLoop::DoWork => DeferOrRunPendingTask => RunTask => debug::TaskAnnotator::RunTask => RunMixin::Run
          - ContextCacheController::OnIdle is called ??
        - ? (find when/how message loop's work initialized)

- Zygote process
  - ? how does it fork-exec to RendererMain

- Gpu process
  - (couldn't track when GPU process is spawned)

- Render process (a.k.a. Renderer)
  - RenderThreadImpl::Create(std::move(main_message_loop), ...)
  - (? RenderViewImpl (deprecating), RenderFrameImpl, RenderWidget)

- Main loop implementation (see comment in message_pump.h. here, assume use_glib is on.)
  - (Thread::Run) => base::RunLoop::Run => MessageLoop::RunHandler => MessagePumpGlib::Run =>
    - while: g_main_context_iteration, MessageLoop::DoWork/DoDelayedWork/DoIdleWork

- multi process architecture
  - http://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code
  - what kind of communication happens ?
    - how blink tells (passes bitmaps to) main browser UI process for window drawing ?
  - ui event example: http://www.chromium.org/developers/design-documents/displaying-a-web-page-in-chrome
  - zygote (docs/linux_zygote.md)
```
