<!--
{
  "title": "Blink Overview (Vol.3)",
  "date": "2017-03-03T17:23:03.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Threads in Renderer

- [Multi-threaded Rasterization in the Chromium Compositor](https://docs.google.com/presentation/d/1nPEC4YRz-V1m_TsGB0pK3mZMRMVvHD1JXsHGr8I3Hvc/edit#slide=id.gb5d9bbc1_035)

- Blink (the place where web happens)
  - Skia Recording
- Compositing thread (threaded compositing)
- Raster thread (Impl side painting)

- Final rendering
  - http://www.chromium.org/developers/design-documents/chromium-graphics/surfaces
  - http://www.chromium.org/developers/design-documents/gpu-command-buffer
  - https://docs.google.com/presentation/d/1ou3qdnFhKdjR6gKZgDwx3YHDwVUF7y8eoqM3rhErMMQ/edit#slide=id.p

```

(inheritance)

(topology)

[main]
cc::ProxyMain
'-' LayerTreeHost

LayerTreeHost
'-' Layer (root layer)
    '-* Layer
'-' RenderWidgetCompositor (as LayerTreeHostClient)
    '-' RenderWidgetCompositor
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
 '-' LayerTreeHostImpl
    '-' LayerTreeImpl (active one and pending one)
    '-' RendererCompositorFrameSink (as CompositorFrameSink)

LayerTreeImpl
'-* PictureLayerImpl
'-* LayerImpl
    '-' RenderSurfaceImpl

FrameData
'-* LayerImpl
'-* RenderPass
    '-* DrawQuad

CompositerFrame

# Main thread and Impl thread

[blink: document lifecycle]
? =>
- ProxyMain::BeginMainFrame =>
  - LayerTreeHost::AnimateLayers
  - cc::LayerTreeHostInProcess::RequestMainFrameUpdate => RenderWidgetCompositor::UpdateLayerTreeHost =>
    RenderWidget::UpdateVisualState => WebViewFrameWidget::updateAllLifecyclePhases => ... =>  FrameView::updateAllLifecyclePhases(PaintClean)
  - ImplThreadTaskRunner()->PostTask(.. ProxyImpl::NotifyReadyToCommitOnImpl ...)
  - CompletionEvent::Wait

Q. how does blink initialize/mutate LayerTreeHost's Layers ?

ex.
PaintLayerCompositor::updateIfNeeded => GraphicsLayerUpdater::update => ... => CLM::updateGraphixsLayerGeometry (or updateGraphicsLayerConfiguration) => updateXXX (e.g. updateTransform) => GL::setXXX => GL::performLayer, WebLayerImpl::setXXX => cc::Layer::setXXX

ex.
CLM::createGraphicsLayer => GL::create =>GL::GL => WebCompositorSupportImpl::createContentLayer => WebContentLayerImpl:: => WebLayerImpl::, PictureLayer::create

[impl: commit]
- ProxyImpl::ScheduledActionCommit =>
  - LayerTreeHost::FinishCommitOnImplThread

[raster?]
(as command buffer and as real GL execution)

[impl: draw]
? =>
- ProxyImpl::DrawInternal =>
  - LTHI::PrepareToDraw => CalculateRenderPass =>
    - TrackDamageForAllSurfaces => DamageTracker::UpdateDamageTrackingState (for RenderSurface)
    - RenderSurfaceImpl::AppendQuads
  - LayerTreeHostImpl::DrawLayers =>
    - initialize CompositerFrame
    - CompositerFrameSink::SubmitCompositerFrame => ... => send ViewHostMsg_SwapCompositorFrame

[impl: ui event hanlder]
- compositer scroll handler ...
```