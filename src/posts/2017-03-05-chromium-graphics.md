<!--
{
  "title": "Chromium Graphics",
  "date": "2017-03-05T17:06:36.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

```
# Class Diagrams

content::Shell
'-* Shell (windows_)
'-' views::Widget
'-' gfx::NativeWindow (aka aura::Window)
'-' WebContents

views::Widget
'-' RootView
'-' DesktopNativeWidgetAura (as NativeWidget)
    '-' aura::Window
        '-' ui::Layer (since aura::Window is LayerOwner)
    '-' DesktopWindowTreeHostX11 (as DesktopWindowTreeHost and as aura::WindowTreeHost)
        '-' XID (represents XWindow)
        '-' ui::Compositor
            '-' ui::Layer (root_layer)
                '-' cc::Layer
            '-' cc::LayerTreeHost (single threaded version, no impl thread)
            '-' cc::Layer (root_web_layer)
            '-' GpuProcessTransportFactory (as ui::ContextFactory)
            '-' cc::FrameSinkId
            '-' (some x handle) (as gfx::AcceleratedWidget)

GpuChildProcess
'-' ui::GpuService
    '-' gpu::GpuChannelManager
'-' GpuServiceFactory


# glx window initialization

[GPU process]

(main path)
- GpuMain =>
  - GpuInit::InitializeAndStartSandbox => gl::init::InitializeGLOneOff => InitializeGLOneOffImplementation =>
    - InitializeStaticGLBindings =
      - InitializeStaticGLXInternal => (load "libGL.so" and call glxGetProcAddress)
      - new RealGLApi and new RealGLXApi
    - InitializeGLOneOffPlatform => GLSurfaceGLX::InitializeOneOff =>
      - XInitThreads, XOpenDisplay
      - glXQueryVersion
      - CreateDummyWindow => XCreateWindow, glXCreateWindow and destroy
    - gpu::ApplyGpuDriverBugWorkarounds
  - GpuProcess::GpuProcess => ChildProcess
  - new GpuChildThread => new ui::GpuService

(command buffer setup on IPC)
- GpuChannel::OnControlMessageReceived =>
  GpuChannel::OnCreateCommandBuffer  => CreateCommandBuffer =>
  GpuCommandBufferStub::Create => new GpuCommandBufferStub, Initialize =>
  - GLES2Decoder::Create
  - ImageTransportSurface::CreateNativeSurface =>
    - gl::init::CreateViewGLSurface =>
      - new GLSurfaceGLXX11, NativeViewGLSurfaceGLX
      - gl::InitializeGLSurface => InitializeGLSurfaceWithFormat => NativeViewGLSurfaceGLX::Initialize (as GLSurface) =>
        - XCreateWindow, XMapWindow
        - glXCreateWindow
    - new PassThroughImageTransportSurface
  - gl::init::CreateGLContext =>
    - new GLContextGLX
    - InitializeGLContext => GLContextGLX::Initialize (as GLContext) =>
      - CreateHighestVersionContext => CreateContextAttribs => glXCreateContextAttribsARB
  - GLContextGLX::MakeCurrent => glXMakeContextCurrent
  - GLES2DecoderImpl::Initialize => (what now?) some decoder implementation beast

[Browser process]
(main thread)
- BrowserMainLoop::BrowserThreadsStarted (browser startup task) =>
  - BrowserGpuChannelHostFactory::Initialize(true) =>
    - new BrowserGpuChannelHostFactory
    - BrowserGpuChannelHostFactory::EstablishGpuChannel =>
      - EstablishRequest::Create =>
        - new EstablishRequest
        - TaskRunner::PostTask(EstablishOnIO) to BrowserThread::IO
  - ImageTransportFactory::Initialize => new GpuProcessTransportFactory => new cc::SurfaceManager

- PreMainMessageLoopRun => ... => Shell::CreateNewWindow  => Shell::CreateShell =>
  Shell::PlatformCreateWindow => views::Widget::Init =>
  - DesktopNativeWidgetAura::InitNativeWidget =>
    - Window::Init => new ui::Layer
    - DesktopWindowTreeHost::Create => new DesktopWindowTreeHostX11
    - DesktopWindowTreeHostX11::Init => InitX11Window =>
      - XCreateWindow
      - OnAcceleratedWidgetAvailable =>
        - ui::Compositor::SetAcceleratedWidget (here it doesn't go to GpuProcessTransportFactory::CreateCompositorFrameSink)
      - WindowTreeHost::CreateCompositor => new ui::Compositor =>
        - cc::Layer::Create => new cc::Layer
        - LayerTreeHost::CreateSingleThreaded => new LayerTreeHost
        - LayerTreeHost::SetVisible => SingleThreadedProxy::xxx => cc::Schedular::xxx => ProcessScheduledActions =>
          ScheduledActionBeginCompositorFrameSinkCreation => ScheduleRequestNewCompositorFrameSink

- (ScheduleRequestNewCompositorFrameSink's callback) => RequestNewCompositorFrameSink =>
  cc::LayerTreeHost::xxx => ui::Compositor::xxx (as LayerTreeHostClient) =>
  - GpuProcessTransportFactory::CreateCompositorFrameSink (as ContextFactory) =>
    BrowserGpuChannelHostFactory::EstablishGpuChannel (register callback GpuProcessTransportFactory::EstablishGpuChannel)

- (as callback) => GpuProcessTransportFactory::EstablishGpuChannel
  - CreateContextCommon => new ContextProviderCommandBuffer
  - ContextProviderCommandBuffer::BindToCurrentThread =>
    CommandBufferProxyImpl::Create => Initialize => Send(GpuChannelMsg_CreateCommandBuffer)
    - (payload includes gpu::SurfaceHandle aka gfx::AcceleratedWidget aka DesktopWindowTreeHostX11's xwindow_)
  - new GpuBrowserCompositorOutputSurface
  - new some BeginFrameSource (e.g. GpuVSyncBeginFrameSource)  (DisplaySchedular will be observer)
  - new cc::DisplaySchedular
  - new cc::Display =>
    - DisplaySchedular::SetClient(cc::Display)
    - cc::DisplaySchedular::SetBeginFrameSource
  - new DirectCompositorFrameSink
  - ui::Compositor::SetCompositorFrameSink

(IO thread)
- (posted task) => BrowserGpuChannelHostFactory::EstablishRequest::EstablishOnIO =>
  - GpuProcessHost::Get =>
    -  GpuProcessHost::Init =>
      -  GpuProcessHost::LaunchGpuProcess
      -  GpuChildThread::CreateGpuService =>
        - GpuService::InitializeWithHost => ... (see above)
  - GpuProcessHost::EstablishGpuChannel
    - GpuService::EstablishGpuChannel =>
      - GpuChannelManager:: EstablishChannel =>  CreateGpuChannel => new GpuChannel

Q. gpu process wont's be spawned well when `lldb content_shell`.
- so I can't see breakpoint at GpuProcessTransportFactory::EstablishGpuChannel

Q. I observed GpuChannel::OnCreateCommandBuffer ran 4 times
- offscreen x 2 => onscreen => offscreen

# Actual drawing code path

[browser process]
BeginFrameSource::OnBeginFrame
DisplaySchedular::OnBeginFrameDeriveImpl (as BeginFrameObserver)
cc::DisplaySchedular::DrawAndSwap
cc::Display::DrawAndSwap (as DisplaySchedularClient)
outpitsurface
=> gl command buffer flashing

[gpu process]
=> gl command buffer decoder execution


Q. note that two orthogonal concept using client/service model in graphics
- commad buffer (for centralized GL execution) <= gfx ipc
- surface management (for embedding mulitiple graphics source each other) <= cc ipc

Q. follow Surface's BeginFrameSource ?

- ?
  beginFrameSource::OnBeginFrame -
  DisplayScheduler::OnBeginFrame (as beginframeobserverbase)
  ombeginframederivedimpl - onbeginframedeasline - Attemptdrawandswap - DisplaySchedular::DrawAndSwp =>
  Display::DrawAndSwap (as DisplaySchedularClient) =>
  - GLRenderer::DrawFrames
  - GLRenderer::SwapBuffers (as DirectRendere) =>
  OutputSurface::SwapBuffers (GpuBrowserCompositorOutputSurface::SwapBuffers) =>
  gpu::ContextSupport::Swap (GLES2Implementation::Swap) =>
  GLES2Implementation::SwapBuffers =>
  - GLES2CmdHelper::SwapBuffers =>
  - CommandBufferHelper::Flush

(browser)
- RenderWidgetHostImpl::OnSwapCompositorFrame => RenderWidgetHostViewAura::xxx =>
  - DelegatedFrameHost::SwapDelegatedFrame =>
    - SurfaceFactory::SubmitCompositorFrame =>
      - SurfaceFactory::Create => new Surface
      - Surface::QueueFrame => ActivateFrame =>
        - SurfaceFactory::SurfaceCreated (as PendingFrameObserver) =>
          SurfaceManager::xxx => DisplayCompositor::OnSurfaceCreated (as SurfaceObserver) => nothing ?
        - ??::OnReferencedSurfacesChanged =>
        -  DelegatedFrameHost::SurfaceDrawn (as cc::SurfaceFactory::DrawCallback) => ... => ViewMsg_ReclaimCompositorResources
    - DelegatedFrameEvictor::SwappedFrame => RendererFrameManager::AddFrame => nothing much ?
  - ?? follow until flash frame into native window (supposed to read cc::Display and aura::Window ?)

[browser]
RenderWidgetHostImpl
'-' RenderWidgetHostViewAura (aura::WindowDelegate)
    '-' DelegatedFrameHost
        '-' SurfaceFactory
        '-' DelegatedFrameEvictor (RendererFrameManagerClient)
    '-' aura::Window (aka gfx::NativeView)

SurfaceManager
'-* Surface
'-*' BeginFrameSource to FrameSinkmap

SurfaceFactory
'-' SurfaceManager
'-' Surface (current_surface_)

Surface
'-2 CompositorFrame (pending_frame_ and active_frame_)
'-' BeginFrameSource ???

cc::Display (in GPU process ?)
'-' cc::OutputSurface (e.g content::GpuBrowserCompositorOutputSurface)
    '-' cc::ContextProvider (e.g. ui::ContextProviderCommandBuffer)
        '-'  gpu::ContextSupport (e.g. gpu::gles2::GLES2Implementation)
            '-' CommandBufferHelper (e.g. gpu::gles2::GLES2CmdHelper)
'-' DisplayScheduler (being begimframeobserver)
'-' xx (as BeginFrameSource)
'-' GLRenderer (as DirectRendere)

ui::Display, ui::DisplayManager (I don't believe it's used...)

content::RendererFrameManager (singleton!)
```

# Reference

- glx, x11 things
    - https://cgit.freedesktop.org/xorg/proto/glproto/tree/glxproto.h
    - https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glXIntro.xml