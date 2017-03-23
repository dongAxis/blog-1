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
$ out/Default/content_shell &lt;url&gt;

# layout test (see docs/testing/layout_tests.md)
$ out/Default/content_shell --run-layout-test third_party/WebKit/LayoutTests/css2.1/20110323/abspos-containing-block-initial-001.htm
...(output layout calculation as plain text to stdout)...
layer at (0,0) size 800x600 clip at (0,0) size 785x600 scrollY 50.00 scrollHeight 10120
  LayoutView at (0,0) size 800x600
...

# debug browser process (for some reason, sometimes, browser process&#039;s UI thread locks on some spin lock (base::Internal::SpinLockDelay) when I do step execution.)
$ lldb out/Default/content_shell
(lldb) breakpoint set --name main
(lldb) process launch
(lldb) gui
...

## debug renderer process (https://www.chromium.org/blink/getting-started-with-blink-debugging) ##
# from one shell
$ out/Default/content_shell --no-sandbox --disable-hang-monitor --renderer-startup-dialog

# from another shell
$ lldb -p $(pgrep -f &#039;content_shell --type=renderer&#039;)
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
  - main =&gt; content::ContentMain =&gt;
    - ContentMainRunner::Initialize =&gt;
      - ShellMainDelegate::BasicStartupComplete
      - InitializeMojo
    - ContentMainRunner::Run =&gt; RunNamedProcessTypeMain =&gt; ShellMainDelegate::RunProcess =&gt; ShellBrowserMain =&gt;
    - BrowserMainRunner::Initialize =&gt;
      - SkGraphics::Init
      - BrowserMainLoop::Init =&gt; ShellContentBrowserClient::CreateBrowserMainParts =&gt; new ShellBrowserMainParts
      - BrowserMainLoop::EarlyInitialization =&gt;
        - SetupSandbox =&gt;
          - RenderSandboxLinux::Init =&gt;
            - new base::DelegateSimpleThread(...SandboxIPCHandler...)
            - SimpleThread::Start =&gt; PlatformThread::CreateWithPriority =&gt; CreateThread =&gt; pthread_create(..., ThreadFunc, ...) =&gt; ThreadFunc =&gt; SimpleThread::ThreadMain (override PlatformThread::Delegate::ThreadMain) =&gt;
              - WaitableEvent::Signal (will catched WaitableEvent::wait in later part of SimpleThread::Start)
              - DelegateSimpleThread::Run =&gt; SandboxIPCHandler::Run/HandleRequestFromRenderer (see linux_sandbox_ipc.md for this thread loop)
          - ZygoteHostImpl::Init
          - CreateZygote =&gt; ZygoteCommunication::Init =&gt; ZygoteHostImpl::LaunchZygote =&gt; sandbox::NamespaceSandbox::LaunchProcess
            - ?? =&gt; +1 thread
      - BrowserMainLoop::InitializeToolkit
        - aura::Env::CreateInstance, aura::Env::Init =&gt; ui::PlatformEventSource::CreateDefault =&gt; gfx::GetXDisplay
      - BrowserMainLoop::MainMessageLoopStart =&gt;
        - new base::MessageLoopForUI
        - InitializaMainThread =&gt; new BrowserThreadImpl(BrowserThread::UI, base::MessageLoop::current())
      - BrowserMainLoop::PostMessageLoopStart =&gt; ?? +4 threads
      - BrowserMainLoop::CreateStartupTasks (4 tasks) =&gt; RunAllTasksNow =&gt;
        - PreCreateThreads =&gt; ?? +2 threads
        - CreateThreads =&gt;
          - base::TaskScheduler::CreateAndSetDefaultTaskScheduler =&gt; +5 threads
          - =&gt; BrowserProcessSubThreads (db, file_user_blocking, file, process_launcher, cache, io) +6 threads
        - BrowserThreadsStarted =&gt;
          - InitializeMojo (isn&#039;t it a second time ?)
          - indexed_db_thread_-&gt;Start() =&gt; +1 thread
          - BrowserGpuChannelHostFactory::Initialize
          - ImageTransportFactory::Initialize =&gt; +1 thread
          - CreateAudioManager =&gt; +2 threads
        - PreMainMessageLoopRun =&gt;
          - ShellBrowserMainParts::PreMainMessageLoopStart =&gt;
            - InitializeBrowserContexts =&gt; BrowserContext::Initialize
            - content::Shell::Initialize =&gt; content::Shell::PlatformInitialize (content/shell/browser/shell_views.cc) =&gt;
              - new wm::WMState
              - views::CreateDesktopScreen =&gt; new DesktopScreenX11 =&gt; PlatformEventSource::AddPlatformEventDispatcher(this)
              - =&gt; +1 thread around here (maybe one-off thread for some small task) ??
            - ShellDevToolsManagerDelegate::StartHttpHandler =&gt; DevToolsAgentHost::StartRemoteDebuggingServer =&gt; new DevToolsHttpHandler ...
            - InitializeMessageLoopContext =&gt; Shell::CreateNewWindow =&gt;
              - content::WebContents::CreateParams
              - WebContents::Create =&gt; ... =&gt; WebContentsImpl::Init
                - (create SiteInstance)
                - (create RenderWidgetHost/RenderViewHost/RenderFrameHost)
                - (new WebContentsViewAura and WebContentsViewAura::CreateView)
              - Shell::CreateShell =&gt;
                - new Shell
                - Shell::CreatePlatformWindow =&gt;
                  - window_widget_ = new views::Widget
                  - Widget::Init =&gt;
                    - DesktopTestViewsDelegate::onBeforeWidgetInit =&gt; new DesktopNativeWidgetAura =&gt; new aura::Window
                    - CreateRootView
                    - DesktopNativeWidgetAura::InitNativeWidget =&gt;
                      - aura::Window::Init (for content_window)
                      - aura::Window::Window/Init/Show (for content_window_container)
                      - content_window_container-&gt;AddChild(content_window)
                      - DesktopWindowTreeHost::Create =&gt; new DesktopWindowTreeHostX11 =&gt; ...
                      - DesktopWindowTreeHostX11::Init =&gt;
                        - DesktopWindowTreeHostX11::InitX11Window =&gt;
                          - XCreateWindow
                          - PlatformEventSource::AddPlatformEventDispatcher(this)
                        - aura::WindowTreeHost::InitHost =&gt; ...
                - WindowTreeHost::Show =&gt;
                  - DesktopWindowHostTreeX11::ShowImpl =&gt;
                    - ShowWindowWithState (this actually create window on my PC)
                    - aura::Window::Show 
                - Shell::PlatformSetContents =&gt;
                  - ShellWindowDelegateView::SetWebContents =&gt;
                    - new views::WebView
                    - views::WebView::SetWebContents
                    - views::View::Layout
              - Shell::LoadURL (with GURL &quot;https://www.google.com/&quot;) =&gt; LoadURLForFrame =&gt;
                - NavigationControllerImpl::LoadURLWithParams =&gt;
                  - CreateNavigationEntry
                  - LoadEntry =&gt; NavigateToPendingEntry =&gt; NavigateToPendingEntryInterval =&gt; NavigatorImpl::NavigateToPendingEntry/NavigateToEntry =&gt; RenderFrameHostManager::Navigate/ReinitializeRenderFrame/InitRenderView =&gt; ... =&gt; RenderProcessHostImpl::Init (supposed to spawn renderer via zygote)
                  - RenderFrameHostManager::InitRenderView =&gt; WebContentsImpl::CreateRenderViewForRenderManager =&gt; RenderViewHostImpl::CreateRenderView =&gt; content::mojom::RendererProxy::CreateView (is this from content/common/renderer.mojom ?)
                - WebContentsImpl::Focus =&gt; ... =&gt; RenderWidgetHostViewAura::Focus =&gt; ... =&gt; wm::FocusController::FocusAndActivateWIndow =&gt; ... =&gt; RenderProcessHostImpl::Send(new ViewMsg_SetActive)
    - BrowserMainRunner::Run =&gt;
      - BrowserMainLoop::RunMainMessageLoopParts =&gt; MainMessageLoopRun =&gt; base::RunLoop::Run (see below for main loop flow)
        - g_main_context_iteration =&gt; 
          - when this line passed, my ubuntu&#039;s dock icon is highlighted, why ?? 
          - when try to step in, segmentation fault happens !?
        - MessageLoop::DoWork =&gt; DeferOrRunPendingTask =&gt; RunTask =&gt; debug::TaskAnnotator::RunTask =&gt; RunMixin::Run
          - ContextCacheController::OnIdle is called ??
        - ? (find when/how message loop&#039;s work initialized)

- Zygote process
  - ? how does it fork-exec to RendererMain

- Gpu process
  - (couldn&#039;t track when GPU process is spawned)

- Render process (a.k.a. Renderer)
  - RenderThreadImpl::Create(std::move(main_message_loop), ...)
  - (? RenderViewImpl (deprecating), RenderFrameImpl, RenderWidget)

- Main loop implementation (see comment in message_pump.h. here, assume use_glib is on.)
  - (Thread::Run) =&gt; base::RunLoop::Run =&gt; MessageLoop::RunHandler =&gt; MessagePumpGlib::Run =&gt;
    - while: g_main_context_iteration, MessageLoop::DoWork/DoDelayedWork/DoIdleWork

- multi process architecture
  - http://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code
  - what kind of communication happens ?
    - how blink tells (passes bitmaps to) main browser UI process for window drawing ?
  - ui event example: http://www.chromium.org/developers/design-documents/displaying-a-web-page-in-chrome
  - zygote (docs/linux_zygote.md)
```