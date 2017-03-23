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
&#039;-&#039; LayerTreeHost

LayerTreeHost
&#039;-&#039; Layer (root layer)
    &#039;-* Layer
&#039;-&#039; RenderWidgetCompositor (as LayerTreeHostClient)
    &#039;-&#039; RenderWidgetCompositor
        &#039;-&#039; RenderWidget (as RenderWidgetCompositorDelegate)
            &#039;-&#039; WebViewFrameWidget (as WebWidget)
                &#039;-&#039; WebLocalFrameImpl
                    &#039;-&#039; LocalFrame
                        &#039;-&#039; FrameView
                &#039;-&#039; WebViewImpl
                    &#039;-&#039; WebLayer

GraphicsLayer
&#039;-&#039; WebContentLayerImpl
    &#039;-&#039; WebLayerImpl
        &#039;-&#039; PictureLayer (as Layer)

[impl]
ProxyImpl
 &#039;-&#039; LayerTreeHostImpl
    &#039;-&#039; LayerTreeImpl (active one and pending one)
    &#039;-&#039; RendererCompositorFrameSink (as CompositorFrameSink)

LayerTreeImpl
&#039;-* PictureLayerImpl
&#039;-* LayerImpl
    &#039;-&#039; RenderSurfaceImpl

FrameData
&#039;-* LayerImpl
&#039;-* RenderPass
    &#039;-* DrawQuad

CompositerFrame

# Main thread and Impl thread

[blink: document lifecycle]
? =&gt;
- ProxyMain::BeginMainFrame =&gt;
  - LayerTreeHost::AnimateLayers
  - cc::LayerTreeHostInProcess::RequestMainFrameUpdate =&gt; RenderWidgetCompositor::UpdateLayerTreeHost =&gt;
    RenderWidget::UpdateVisualState =&gt; WebViewFrameWidget::updateAllLifecyclePhases =&gt; ... =&gt;  FrameView::updateAllLifecyclePhases(PaintClean)
  - ImplThreadTaskRunner()-&gt;PostTask(.. ProxyImpl::NotifyReadyToCommitOnImpl ...)
  - CompletionEvent::Wait

Q. how does blink initialize/mutate LayerTreeHost&#039;s Layers ?

ex.
PaintLayerCompositor::updateIfNeeded =&gt; GraphicsLayerUpdater::update =&gt; ... =&gt; CLM::updateGraphixsLayerGeometry (or updateGraphicsLayerConfiguration) =&gt; updateXXX (e.g. updateTransform) =&gt; GL::setXXX =&gt; GL::performLayer, WebLayerImpl::setXXX =&gt; cc::Layer::setXXX

ex.
CLM::createGraphicsLayer =&gt; GL::create =&gt;GL::GL =&gt; WebCompositorSupportImpl::createContentLayer =&gt; WebContentLayerImpl:: =&gt; WebLayerImpl::, PictureLayer::create

[impl: commit]
- ProxyImpl::ScheduledActionCommit =&gt;
  - LayerTreeHost::FinishCommitOnImplThread

[raster?]
(as command buffer and as real GL execution)

[impl: draw]
? =&gt;
- ProxyImpl::DrawInternal =&gt;
  - LTHI::PrepareToDraw =&gt; CalculateRenderPass =&gt;
    - TrackDamageForAllSurfaces =&gt; DamageTracker::UpdateDamageTrackingState (for RenderSurface)
    - RenderSurfaceImpl::AppendQuads
  - LayerTreeHostImpl::DrawLayers =&gt;
    - initialize CompositerFrame
    - CompositerFrameSink::SubmitCompositerFrame =&gt; ... =&gt; send ViewHostMsg_SwapCompositorFrame

[impl: ui event hanlder]
- compositer scroll handler ...
```