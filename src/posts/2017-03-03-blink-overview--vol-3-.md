<!--
{
  "title": "Blink Overview (Vol.3)",
  "date": "2017-03-03T17:23:03.000Z",
  "updated_date": "2017-06-14T00:13:03+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Threads in Renderer

- https://cs.chromium.org/chromium/src/cc/README.md
- https://docs.google.com/presentation/d/1nPEC4YRz-V1m_TsGB0pK3mZMRMVvHD1JXsHGr8I3Hvc/edit#slide=id.gb5d9bbc1_035
- http://www.chromium.org/developers/design-documents/chromium-graphics/surfaces
- http://www.chromium.org/developers/design-documents/gpu-command-buffer
- https://docs.google.com/presentation/d/1ou3qdnFhKdjR6gKZgDwx3YHDwVUF7y8eoqM3rhErMMQ/edit#slide=id.p
- how/where blink main's skia picture is rastered ? and eventually turned into CompositerFrame ?

```
[main]
cc::ProxyMain
'-' LayerTreeHost

LayerTreeHost
'-' Layer (root layer)
  '-* Layer
'-' RenderWidgetCompositor (as LayerTreeHostClient)
  '-' RenderWidget (as RenderWidgetCompositorDelegate)
    '-' WebViewFrameWidget (as WebWidget)
      '-' WebLocalFrameImpl
        '-' LocalFrame
          '-' FrameView
        '-' WebViewImpl
          '-' WebLayer

GraphicsLayer
'-' WebContentLayerImpl
  '-' WebLayerImpl
    '-' PictureLayer (as Layer)

[impl]
ProxyImpl
'-' LayerTreeHostImpl (< CompositorFrameSinkClient)
  '-' LayerTreeImpl (active one and pending one)
  '-' DirectCompositorFrameSink (< CompositorFrameSink)
  '-' TaskGraphRunner

LayerTreeImpl
'-* PictureLayerImpl
'-* LayerImpl
  '-' RenderSurfaceImpl

FrameData
'-* LayerImpl
'-* RenderPass
  '-* DrawQuad

CompositerFrame
'-' RenderPassList
  '-* RenderPass
    '-' QuadList
      '-* DrawQuad (> TileDrawQuad)

Scheduler
'-' ProxyImpl (as client)
'-' SchedulerStateMachine

TileManager
'-' LayerTreeHostImpl (< TileManagerClient)
'-' TileTaskManagerImpl
  '-' TaskGraphRunner

RasterTaskImpl < TileTask < Task
'-' TileTask::Vector dependencies_
'-' OneCopyRasterBufferProvider::RasterBufferImpl (< RasterBuffer)
'-' RasterSource
  '-' DisplayItemList


[compositor (browser)]

GpuBrowserCompositorOutputSurface (< BrowserCompositorOutputSurface (< OutputSurface))
'-' ContextProviderCommandBuffer (< ContextProvider)
'-' Display (< OutputSurfaceClient)
'-' gpu::CommandBufferProxyImpl

(!! something seems wrong (are we already moved to display compositor (or viz) ? not browser compositor anymore ?))
DisplaySchedular (< BeginFrameObserverBase, < SurfaceObserver)
'-' Display (< DisplaySchedularClient)
  '-' DirectCompositorFrameSink (< DisplayClient, < CompositorFrameSink)
    '-' LayerTreeHostImpl (< CompositorFrameSinkClient) ?? (does renderer keep Display ??)
  '-' GLRenderer (< DirectRenderer)

SurfaceManager
'-' base::ObserverList<SurfaceObserver>
'-' std::unordered_map<SurfaceId, Surface*, SurfaceIdHash>

Surface
'-2 FrameData (pending_frame_data_ and active_frame_data_)

GpuVSyncBeginFrameSource (< ExternalBeginFrameSource < BeginFrameSource, < ExternalBeginFrameSourceClient)
'-' ?


# browser <-> blink impl <-> blink main

[browser: request frame to impl]
- IPC_MESSAGE_HANDLER(ViewMsg_BeginFrame, OnBeginFrame) =>
  - CompositorExternalBeginFrameSource::OnBeginFrame =>
    - ExternalBeginFrameSource::OnBeginFrame =>
      - BeginFrameObserverBase::OnBeginFrame =>
        - Scheduler::OnBeginFrameDerivedImpl =>
          - BeginImplFrameWithDeadline => BeginImplFrame =>
            - LayerTreeHostImpl::WillBeginImplFrame =>
              - Animate => AnimateInternal =>
                - Mutate =>
                  - AnimateLayers ...
                  - SetNeedsOneBeginImplFrameOnImplThread =>
                    - SetNeedsOneBeginImplFrame =>
                      - state_machine_.SetNeedsOneBeginImplFrame =>
                        - needs_one_begin_impl_frame_ = true
                      - ProcessScheduledActions => ...??


[impl: request frame to main]
- Scheduler::ProcessScheduledActions =>
  - SchedulerStateMachine::ACTION_SEND_BEGIN_MAIN_FRAME (aka SchedulerStateMachine::ShouldSendBeginMainFrame)
    - ProxyImpl::ScheduledActionSendBeginMainFrame =>
      - MainThreadTaskRunner()->PostTask(.. ProxyMain::BeginMainFrame ..)


[main: document lifecycle]
- ProxyMain::BeginMainFrame =>
  - LayerTreeHost::AnimateLayers
  - cc::LayerTreeHostInProcess::RequestMainFrameUpdate => RenderWidgetCompositor::UpdateLayerTreeHost =>
    RenderWidget::UpdateVisualState => WebViewFrameWidget::updateAllLifecyclePhases => ... =>
    FrameView::updateAllLifecyclePhases(PaintClean) => ...
  - ImplThreadTaskRunner()->PostTask(.. ProxyImpl::NotifyReadyToCommitOnImpl ...)
  - CompletionEvent::Wait


[impl: commit]
- ProxyImpl::NotifyReadyToCommitOnImpl =>
  - blocked_main_commit().layer_tree_host = layer_tree_host;
  - Schedular::NotifyReadyToCommit =>
    - begin_main_frame_state_ = BEGIN_MAIN_FRAME_STATE_READY_TO_COMMIT
    - ProcessScheduledActions =>
      - SchedulerStateMachine::NextAction => ACTION_COMMIT
      - SchedulerStateMachine::WillCommit => ??
      - ProxyImpl::ScheduledActionCommit =>
        - blocked_main_commit().layer_tree_host->FinishCommitOnImplThread =>
          - LayerTreeImpl* sync_tree = host_impl->sync_tree()
          - TreeSynchronizer::SynchronizeTrees(root_layer(), sync_tree)
          - ...
        - blocked_main_commit().layer_tree_host = nullptr


[browser: request to blink]
- only by test ? =>
  - RenderWidgetHostImpl::ScheduleComposite =>
    - Send(new ViewMsg_Repaint ..)


[main: draw request to impl]
- IPC_MESSAGE_HANDLER(ViewMsg_Repaint, OnRepaint) => OnRepaint =>
  - RenderWidgetCompositor::SetNeedsRedrawRect =>
    - LayerTreeHost::SetNeedsRedrawRect => ProxyMain::SetNeedsRedraw =>
      - ImplThreadTaskRunner()->PostTask(.. ProxyImpl::SetNeedsRedrawOnImpl ..)


[impl: tile rastering sheduling ]
- ? => Scheduler::ProcessScheduledActions =>
  - (when SchedulerStateMachine::shouldPrepareTiles() aka ACTION_PREPARE_TILES)
    ProxyImpl::ScheduledActionPrepareTiles =>
    - LayerTreeHostImpl::PrepareTiles => TileManager::PrepareTiles =>
      - TileManager::AssignGpuMemoryToTiles =>
        - LayerTreeHostImpl::BuildRasterQueue (as client_->BuildRasterQueue) =>
          - RasterTilePriorityQueue::Create(active_tree_->picture_layers(), pending_tree_->picture_layers() ..) =>
            - ??
        - prioritized_tile = raster_priority_queue->Top
        - tile->raster_task_ = TileManager::CreateRasterTask(prioritized_tile, ...) =>
          - new RasterTileTask(.. prioritized_tile.raster_source() ..)
        - work_to_schedule.tiles_to_raster.push_back(prioritized_tile)
      - TileManager::ScheduleTasks =>
        - tile_task_manager_->ScheduleTasks => ...


[tile worker: tile rastering]
(worker thread)
- ? =>
  - TileManager::RunOnWorkerThread =>
    - RasterBuffer::Playback (e.g. OneCopyRasterBufferProvider::RasterBufferImpl) =>
      - RasterizeSource => RasterSource::PlaybackToCanvas => RasterCommon =>
        - DisplayItemList::Raster =>
          - PaintOpBuffer::PlaybackRanges =>
            - PaintOp::Raster (e.g. ??) =>
              - SkCanvas::??

(impl thread)
- TileManager::PrepareTiles => TileTaskManagerImpl::CheckForCompletedTasks =>
  - TileManager::OnTaskCompleted => OnRasterTaskCompleted =>
    - TileDrawInfo::set_resource
    - TileDrawInfo::set_resource_ready_for_draw => is_resource_ready_to_draw_ = true


[impl: draw]
- ProxyImpl::SetNeedsRedrawOnImpl =>
  - layer_tree_host_impl_->SetViewportDamage
  - ProxyImpl::SetNeedsRedrawOnImplThread => Scheduler::SetNeedsRedraw =>
    -  SchedulerStateMachine::SetNeedsRedraw => needs_redraw_ = true
  - ProcessScheduledActions =>
    - SchedulerStateMachine::ACTION_DRAW_IF_POSSIBLE (aka SchedulerStateMachine::ShouldDraw or needs_redraw_)
      - ProxyImpl::ScheduledActionDrawIfPossible =>
        - ProxyImpl::DrawInternal =>
          - LTHI::PrepareToDraw =>
            - LayerTreeImpl::UpdateDrawProperties =>
            - CalculateRenderPasses =>
              - TrackDamageForAllSurfaces => DamageTracker::UpdateDamageTrackingState (for RenderSurface)
              - for (EffectTreeLayerListIterator it(active_tree()) ..)
                - EffectTreeLayerListIterator::State::LAYER
                  - LayerImpl::AppendQuads (e.g. PictureLayerImpl::AppendQuads) =>
                    - for (PictureLayerTilingSet::CoverageIterator ..)
                      - if TileDrawInfo::IsReadyToDraw (aka is_resource_ready_to_draw_)
                        - TileDrawQuad::CreateAndAppendDrawQuad
                        - TileDrawQuad::SetNew
          - LayerTreeHostImpl::DrawLayers =>
            - CompositorFrameMetadata metadata = MakeCompositorFrameMetadata
            - CompositorFrame compositor_frame
            - DirectCompositorFrameSink::SubmitCompositorFrame (?) =>
              - CompositorFrameSinkSupport::SubmitCompositorFrame =>
                - Surface::QueueFrame => Surface::ActivateFrame =>
                  - CompositorFrameSinkSupport::OnSurfaceActivated
          - MainThreadTaskRunner()->PostTask(.. ProxyMain::DidCommitAndDrawFrame ..)


["Display drawing": draw frame]
- GpuVSyncBeginFrameSource::OnVSync =>
  - ExternalBeginFrameSource::OnBeginFrame =>
    BeginFrameObserver::OnBeginFrame (e.g. DisplaySchedular as BeginFrameObserverBase) =>
    DisplayScheduler::OnBeginFrameDerivedImpl =>
    OnBeginFrameDeadline => AttemptDrawAndSwap => DrawAndSwap =>
    - Display::DrawAndSwap =>
      - DirectRenderer::DrawFrames =>
        - DirectRenderer::DrawRenderPassAndExecuteCopyRequests =>
          - DirectRenderer::DrawRenderPass =>
            - GLRenderer::PrepareSurfaceForPass => ...
            - GLRenderer::DoDrawQuad =>
              - (e.g. DrawTileQuad) => DrawContentQuad => DrawContentQuadAA =>
                - SetUseProgram(ProgramKey::Tile ...) =>
                  - gl_->UseProgram
                  - gl_->ActiveTexture
                - DrawQuadGeometry => gl_->DrawElements
          - DirectRenderer::UseRenderPass =>
            - GLRenderer::BindFramebufferToTexture
          - GLRenderer::CopyCurrentRenderPassToBitmap =>
            - GetFramebufferPixelsAsync => ...
      - GLRenderer::SwapBuffers => GpuBrowserCompositorOutputSurface::SwapBuffers =>
        - ContextProviderCommandBuffer::ContextSupport
        - gpu::gles2::GLES2Implementation::Swap => SwapBuffers => ...
---

others ...

[impl: ui event hanlder]
- LayerTreeHostImpl's input_handler_client_ ?
- compositer scroll handler ...


ex.
- PaintLayerCompositor::updateIfNeeded => GraphicsLayerUpdater::update => ... =>
  - CLM::updateGraphixsLayerGeometry (or updateGraphicsLayerConfiguration) =>
    - updateXXX (e.g. updateTransform) => GL::setXXX =>
      - GL::performLayer, WebLayerImpl::setXXX => cc::Layer::setXXX

ex.
- CLM::createGraphicsLayer => GL::create => GL::GL =>
  - WebCompositorSupportImpl::createContentLayer => WebContentLayerImpl::
    - => WebLayerImpl::, PictureLayer::create
```


(from chrome://gpu)
Graphics Feature Status
Compositing: Hardware accelerated
Multiple Raster Threads: Enabled
Native GpuMemoryBuffers: Software only. Hardware acceleration disabled
Rasterization: Software only. Hardware acceleration disabled

Compositor Information
Tile Update Mode	One-copy
Partial Raster	Enabled
