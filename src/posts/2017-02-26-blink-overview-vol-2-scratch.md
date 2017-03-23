<!--
{
  "title": "Blink Overview (Vol. 2)",
  "date": "2017-02-26T00:41:41.000Z",
  "category": "",
  "tags": [
    "scratch"
  ],
  "draft": false
}
-->

```
# Inheritance

- LayoutObject 
  - LayoutBoxModelObject
    - LayoutInline (inline box a.k.a. non-block inline-level box)
    - LayoutBox (block-level box ?)
      - LayoutReplaced (replaced block)
      - LayoutBlock (containing block)
        - LayoutBlockFlow (block container)
          - LayoutView (initial containing block a.k.a. viewport)
        - LayoutFlexibleBox (?)
  - LayoutText (anything that represents text node)

- InlineBox
  - InlineFlowBox (line box)
    - RootInlineBox (?)
  - InlineTextBox (single &quot;text run&quot; level entity?)

- FloatingObject

# Topology

Document
&#039;-&#039; LayoutView

Node
&#039;-&#039; LayoutObject

LayoutBoxModelObject
&#039;-&#039; PaintLayer

LayoutObject 
&#039;-&#039; ComputedStyle

ComputedStyle
&#039;-&#039; StyleBoxData (as m_box)
&#039;-&#039; etc...

LayoutItem
&#039;-&#039; LayoutObject

LayoutBox
&#039;-&#039; BoxOverflowModel

LayoutView
&#039;-&#039; LayoutState
&#039;-&#039; PaintLayerCompositor (supposedly replaced with PaintArtifactCompositor for SPv2)

LayoutBlock
&#039;-* LayoutObject  (as m_children)

LayoutBlockFlow
&#039;-* InlineFlowBox  (as m_lineBoxes)

LayoutInline
&#039;-*  LayoutObject   (as m_children)
&#039;-*  InlineFlowBox  (as m_lineBoxes)

LayoutText
&#039;-* InlineTextBox (as m_{first,last}TextBox)

InlineFlowBox
&#039;-*  InlineBox (as m_{first,last}Child)

InlineBox
&#039;-&#039;  LayoutObject (as m_lineLayoutItem)

(Inheritance)	 	 
- cc::LayerClient	 	 
  - GraphicsLayerClient	 	 
  - PaintLayerCompositor	 
	 
- DisplayItemClient	 	 
  - LayoutObject
  - PaintLayer
  - GraphicsLayer

- GraphicsLayerClient
  - CompositedLayerMapping

- WebLayer
  - WebLayerImpl

(Topology)
PaintLayerCompositor (being replaced for SPv2)	 	 
&#039;-&#039; PaintLayer (as root layer)	 	 
&#039;-* GraphicsLayer

PaintLayer	 	 
&#039;-&#039; LayoutBoxModelObject
&#039;-* PaintLayer (as children node)
&#039;-&#039; LayoutPoint
&#039;-&#039; CompositedLayerMapping (rare data) (squashed to others or its own)
&#039;-&#039; AncestorDependentCompositingInputs
   &#039;-* PaintLayer (track some special kind of ancestor e.g. opacityAncestorer, transformAncestor, filterAncestor, clipParent)
&#039;-&#039; PaintLayerStackingNode (track z-index ordered nodes)

PaintLayerStackingNode
&#039;-* PaintLayerStackingNode (as posZOrderList)
&#039;-* PaintLayerStackingNode (... neg)

CompositedLayerMapping
&#039;-&#039; PaintLayer
&#039;-* GraphicsLayer (bunch of types, their hierarchy is explained as commemt)
&#039;-&#039; GraphicsLayer (m_squashingLayer)
&#039;-* GraphicsLayerPaintInfo (m_squashedLayers)
    &#039;-&#039; PaintLayer

GraphicsLayer	 	 
&#039;-* GraphicsLayer
&#039;-&#039; GraphicsLayerClient (normally CompositeLayerMapping)
&#039;-&#039; PaintController
&#039;-&#039; WebContentLayer
    &#039;-&#039; WebLayer
        &#039;-&#039; cc::Layer
&#039;-&#039; WebContentLayerClient

GraphicsContext
&#039;-&#039; PaintCanvas (SkCanvas)
&#039;-&#039; PaintController
&#039;-* GraphicsContextState (paint states as stack)
&#039;-&#039; SkMetaData

PaintLayerFragment
&#039;-* Rect (bunch of types of ClipRect and LayoutRect)

PaintLayerPainter (for self-painting PaintLayer)
&#039;-&#039;  PaintLayer

PaintController
&#039;-&#039; DisplayItemList
  &#039;-* DisplayItem
  &#039;-* IntRect (visualRects)

DisplayItem	 	 
&#039;-&#039; DisplayItemClient	 	 
&#039;-&#039; DisplayItem::Type	 	 

---

# Layout entry point

- FrameView::layout =&gt;
  - performPreLayoutTask =&gt;
    - advanceTo(DocumentLifecycle::InPreLayout)
    - Document::mediaQuery...
    - updateStyleAndLayoutTree (see http://wp.hiogawa.net/2017/02/07/blink-overview/)
    - advanceTo(DocumentLifecycle::StyleClean)
  - performLayout =&gt;
    - advanceTo(DocumentLifecycle::InPerformLayout)
    - layoutFromRootObject =&gt;
      - LayoutView::layout =&gt;
        - initialize SubtreeLayoutScope
        - SubtreeLayoutScope::setChildNeedsLayout (for children with size isPercentOrCalc)
        - initialize  LayoutState 
        - layoutContent =&gt; LayoutBlock::layout =&gt; (see below)
    - advanceTo(DocumentLifecycle::AfterPerformLayout)
  - scheduleOrPerformPostLayoutTasks

- LayoutBlock::layout =&gt; LayoutBlockFlow::layoutBlock(false) =&gt;
  - simplifiedLayout (?)
  - updateLogicalWidthAndColumnWidth =&gt; ... =&gt; LayoutView::layoutSize =&gt; FrameView::layoutSize
  - layoutChildren (loop this if something failed it? not in the sense of traversing some tree structure ?) =&gt;
    - setLogicalHeight (?)
    - layoutBlockChildren =&gt;
      - (for each child)
        - (special care for child if it isOutOfFlowPositioned, isFloating, isColumnSpanAll)
        - (but, normally) layoutBlockChild =&gt;
          - computeAndSetBlockDirectionMargin
          - estimateLogicalTopPosition
          - positionAndLayoutOnceIfNeeded =&gt;
            - setLogicalTopForChild
            - LayoutBlock::layout (recursively back to the flow above for this child) =&gt; ...
          - determineLogicalLeftPositionForChild
          - setLogicalHeight (add up child&#039;s height)
        - handleAfterSideOfBlock =&gt;
          - setLogicalHeight (add up bottom margin)
    - setLogicalHeight (some float things)
  - layoutPositionedObjects
  - updateLayerTransformAfterlayout =&gt; 

(for non LayoutView)
- LayoutBlock::updateLogicalWidthAndColumnWidth =&gt; LayoutBox::updateLogicalWidth =&gt; computeLogicalWidth =&gt;
  - containingBlockLogicalWidthForContent
  - computeMarginsForDirection


Q. why is LayoutView::layout called 5 times for my example?

- WebView initialization =&gt; FrameView::layout =&gt;
  - performLayout =&gt; LayoutView::layout
  - adjustViewSizeAndLayout =&gt; ... =&gt; scrollbarExistenceDidChanged =&gt; LayoutView::layout
  - Document::layoutUpdated =&gt; ... =&gt; scrollbarExistenceDidChanged =&gt; LayoutView::layout

- TaskQueueManager::DoWork =&gt; ... =&gt; HTMLParserSchedular::continueParsing =&gt; ... =&gt; Document::implicitClose =&gt; FrameView::layout 
- FrameView::updateAllLifecyclePhases =&gt; ... =&gt; layout

not sure why last one is necessary ? Anyway, it looked like the second last one is something.

Q. Document vs LayoutView

- are these two different ?
  - document.m_layoutView
  - document.m_data.m_rareData.m_layoutObject (as Node)

Q. is there corresponding class, which represents root layer in layout test output ? or is this only for debugging reason ?

layer at (0,0) size 800x600
  LayoutView at (0,0) size 800x600
layer at (0,0) size 800x216
  LayoutBlockFlow {HTML} at (0,0) size 800x216
    LayoutBlockFlow {BODY} at (8,8) size 784x200
      LayoutBlockFlow {DIV} at (0,0) size 200x200 [bgcolor=#FF0000]
        LayoutBlockFlow {DIV} at (0,0) size 100x50 [bgcolor=#0000FF]
        LayoutBlockFlow {DIV} at (0,50) size 200x100 [bgcolor=#008000]

# Paint

- FrameView::updateAllLifecyclePhases(PaintClean) =&gt; updateLifecyclePhasesInternal =&gt;
  -  PaintLayerCompositor::updateIfNeededRecursive =&gt; updateIfNeededRecursiveInternal (for each nested frame) =&gt;
    - advanceTo(InCompositingUpdate)
    - updateIfNeeded (see below)
    - advanceTo(DocumentLifecycle::CompositingClean)
  - FrameView::prepaint (? is this only for SPv2)
  - FrameView::paintTree (see below)

- updateIfNeeded
  - CompositingInputsUpdater::update =&gt; updateRecursive =&gt;
    - initialize PaintLayer::AncestorDependentCompositingInputs
    - updateRecursive (for each child PaintLayer)
  - CompositingRequirementsUpdater::update =&gt; updateRecursive =&gt;
    - updateLayerListsIfNeeded =&gt; ... =&gt; PaintLayerStackingNode::rebuildZOrderList ...
    - lots of CompositingReason ... (read later)
    - updateRecursive (for each stacked object under this PaintLayer)
    - PaintLayer::setCompositeReason
  - CompositingLayerAssigner::assign =&gt; assignLayersToBackingsInternal =&gt;
    - determine &quot;squash&quot;-ability by checking CompositingReason
    - updateSquashingAssignment =&gt;
      - CompositingLayerMapping::updateSquashingLayerAssignment =&gt;
        - Vector&lt;GraphicsLayerPaintInfo&gt;::insert ? (squash into squashingState.mostRecentMapping)
        - PaintLayer::setGroupedMapping ?
    - assignLayersToBackingsInternal (for each stacked object)
  - updateClippingOnCompositorLayers (some root frame layer scroller thing?)
  - GraphicsLayerUpdater::update =&gt; updateRecursive =&gt;
    - CompositedLayerMapping::updateGraphicsLayerConfiguration =&gt;
      - updateXXXLayers (e.g. updateSquashingLayers) =&gt;
        - createGraphicsLayer =&gt; GraphicsLayer::Create
    - CompositeLayerMapping::updatteGraphicsLayerGeometry =&gt;
      - ... GraphicsLayer::setXXX (e.g. Transform, Position, ...) =&gt; WebLayerImpl::setPosition
    - updateRecursive (for each child PaintLayer)
  - GraphicsLayerTreeBuilder::rebuild =&gt;
    - rebuild (for NegativeZOrderChildren)
    - rebuild (for NormalFlowChildren and PositiveZOrderChildren)
    - ? what&#039;s up with stuff around GraphicsLayerVector

- FrameView::paintTree =&gt; paintGraphicsLayerRecursively =&gt;
  - GraphicsLayer::paint (if drawsContent)  =&gt;
    - paintWithoutCommit =&gt;
      - CompositedLayerMapping::computeInterestRect
      - initialize GraphicsContext
      - CompositedLayerMapping::paintContents =&gt; doPaintTask (for its own or for each squashed paint layer) (go below)
    - PaintController::commitNewDisplayItems =&gt;
      - DisplayItemList::appendVisualRect (for each DisplayItem)
      - what&#039;s up with &quot;commit&quot; ?
  - paintGraphicsLayerRecursively (for mask layer and each child GraphicsLayer)

- CompositedLayerMapping::doPaintTask =&gt;
  - (non-squashed case) PaintLayerPainter::paintLayerContents =&gt;
    - initialize PaintLayerFragments
    - paintXXXforFragments (e.g. paintBackgroundForFragments) =&gt; paintFragmentWithPhase(PaintPhaseSelfBlockBackgroundOnly, ...) =&gt;
      - process PaintInfo, LayoutOffset
      - LayoutObject::paint(PaintInfo, LayoutOffset) (e.g. LayoutBlock::paint) (see below)
    - paintChildren (in terms of zOrderNeg and zOrderPos) =&gt;
      - PaintLayerPainter::paint =&gt;
        - paintLayerWithTransform =&gt; paintFragmentByApplyingTransform =&gt; paintLayerContentsCompositingAllPhases =&gt; paintLayerContents
        - (or directly) paintLayerContentsCompositingAllPhases =&gt; paintLayerContents
  - (squashed case)
    - PaintLayerPainter::paint =&gt; (see above)

- LayoutBlock::paint =&gt; ...

Q. categorize the way LayoutObject is painted.

- with paintlayer (every layout box has it)
  - self painting flag true
    - enum CompositingState
      - PaintsIntoGroupedBacking
      - PaintsIntoOwnBacking
      - NotComposited
  - self painting flag false
    - in this case, PaintLayer is not used for painting it and some ancestor layoutblock will take care it within BlockPainter::paintChildren.

Q. how is this categorization done?

- when self-painting flag is on ?
- when do we compose ?
  - when do we squash ?

Q. when/why do we squash ? when we squash is related to zorder ? when paintleyer gets self painting flag ?

(is squashing related compositing ?)

Q. compositing happens in two levels ?

- 1. composite PaintLayers within grouped backing (CompositedLayerMapping)
  - I guess, this shouldn&#039;t be called &quot;compositing&quot;. squashing is only for resource saving purpose?
- 2. composite GraphicsLayers ?? who does that ? (impl side compositing ?)

Q. how to see log from TRACE_EVENT0 ?

- see http://www.chromium.org/developers/how-tos/trace-event-profiling-tool

# Recording on Blink

(topology)
LayoutObjectDrawingRecorder
&#039;-&#039; DrawingRecorder
    &#039;-&#039; GraphicsContext
    &#039;-&#039; DisplayItemClient
    &#039;-&#039; DisplayItem::Type

GraphicsContext
&#039;-&#039; SkCanvas
&#039;-&#039; ...

[procedures]

- PaintLayerPainter::paintLayerContents =&gt;
- paintBackgroundForFragments =&gt; ... =&gt; LayoutView::paint
  - ViewPainter::paint =&gt;
    - LayoutBlock::paintObject =&gt; BlockPainter::paintObject =&gt;
      - LayoutView::paintBoxDecorationBackground =&gt; ViewPainter::xxx =&gt;
        - create LayoutObjectDrawingRecorder
        - GraphicsContext::fillRect =&gt;
          - GraphicsContextState::fillPaint (or synonym filleFlags)
          - drawRect =&gt; SkCanvas::drawRect =&gt; onDrawRect =&gt; some magics... (TRY_MINIRECORDER and APPEND macro)
- paintChildren(NegativeZOrderChildren) =&gt; ... (no children for my example)
- paintForegroundForFragments =&gt; ...(same flow as above but phase is now different) =&gt;
  - BlockPainter::paintObject =&gt;
    - BlockFlowPainter::paintContents =&gt; BlockPainter::paintContents =&gt; LayoutBlock::paintChildren =&gt;
      - BlockPainter::paintChildren =&gt; paintChild (for each child LayoutBox) =&gt;
        - LayoutBox::paint (only for non-self-painting child) (actually nothing matched for my example)
- paintChildren(NormalFlowChildren | PositiveZOrderChildren) =&gt;
  - PaintLayerPainter::paint =&gt; ... =&gt; paintLayerContents =&gt;

[nest level for my example]

- GraphicsLayer::paint =&gt; paintWithoutCommit =&gt; CLM::paintContents =&gt; doPaintTask =&gt;
  - paintLayerContents =&gt;
    - paintBackgroundForFragments =&gt; ... =&gt; LayoutView::paint =&gt; Graphics::drawRect
    - paintChildren(NormalFlow or PosZOrder) =&gt; ... =&gt;
      - paintLayerContents =&gt;
        - paintBackgroundForFragments (I missed it again ...)
        - paintForegroundForFragments =&gt; ... =&gt;
          LayoutBlock/BlockPainter::paint =&gt;
            - (several paintObject calls with different locally patched paintPhase (localPaintInfo.phase), which leads to different parts in paintObject)
            - LayoutBlock/BlockPainter::paintObject =&gt;
              - paintDecorationBackground, paintMask, etc... (depending on self-painting-ness and paintPhase)
              - BlockFlowPainter/BlockPainter::paintContents =&gt; LayoutBlock/BlockPainter::paintChildren =&gt;
                - paintChild (for each child LayoutBox) =&gt; LayoutBlock/BlockPainter::paint (repeat above)

Q. what is LayoutUnit ?

for example, in LayoutView::updateLogicalWidth, LayoutUnit ::LayoutUnit(int ) converts value to 6 bit shifted as in kLayoutUnitFractionalBits = 6, which is same as multiplication by 64.
So, if Viewport is 800x600, layoutView&#039;s m_frameRect will be 51200x38400

Q. what belongs to Foreground and what belongs to NormalFlowChildren ?

- non-self-painting children will go to some ancestor&#039;s Fourground contents
- self-painting children will go to some ancestor&#039;s NormalFlowChildren


# frame lifecycle and its entrypoint

- RenderView initialization (see Blink Overview Vol. 1)
  - RenderThreadImpl::CreateView =&gt; ... =&gt; WebViewImpl::updateAllLifecyclePhase =&gt;
    - PageWidgetDelegate::updateAllLifecyclePhases =&gt; ... =&gt; FrameView::updateAllLifecyclePhases(PaintClean)
    - content::RenderWidget::didMeaningFullLayout (as WebWidgetClient) =&gt;
      - QueueMessage(new ViewHostMsg_didFirstVisuallyNonEmptyPaint, ...) =&gt; must be something ?? maybe not, considering anyway renderer needs impl side compositing.

- * Queued task (how??)
  - ... =&gt; TaskQueueManagerDoWork =...=&gt; cc::ProxyMain::BeginMainFrame =&gt;
    cc::LayerTreeHostInProcess::RequestMainFrameUpdate =&gt; RenderWidgetCompositor::UpdateLayerTreeHost =&gt;
    RenderWidget::UpdateVisualState =&gt; WebViewFrameWidget::updateAllLifecyclePhases =&gt; WebViewImpl::xxx =&gt; ...

- ui event handler (hit testing) on main thread
  - ... =&gt; TaskQueueManagerDoWork =&gt; content::MainThreadEventQueue::DispatchSingleEvent =&gt; DispatchInFlightEvent =&gt;
    InputEventFilter::HandleEventOnMainThread =&gt; ChildThreadImpl::OnMessageReceived =&gt; MessageRouter::xxx =&gt;
    ChildThreadImpl::ChildThreadMessageRouter::RouteMessage =&gt; IPC::MessageRouter::xxx =&gt;
    RenderViewImpl::OnMessageReceived =&gt; IPC_MESSAGE_HANDLER(InputMsg_HandleInputEvent, OnHandleInputEvent) =&gt; (some IPC magic) =&gt;
    RenderWidget::OnHandleInputEvent =&gt; RenderWidgetInputHandler::HandleInputEvent =&gt; WebViewFrameWidget::handleInputEvent =&gt;
    WebViewImpl::handleInputEvent =&gt; PageWidgetDelegate::xxx =&gt; e.g. handleMouseMove =&gt;
    EventHandler::handleMouseMoveEvent =&gt; handleMouseMoveOrLeaveEvent =&gt; EventHandlingUtil::performMouseEventHitTest =&gt;
    Document::xxx =&gt; LayoutViewItem::hitTest =&gt; LayoutView::histTest =&gt; ... follow until you find Element to dispatch event ??
    

  - ?? =&gt; LayoutView::hitTest =&gt; ?? =&gt; FrameView::updateAllLifecyclePhases(CompositingClean) =&gt;

- how about impl thread ??
  - does this happen on WebViewImpl::handleInputEvent, I guess ??
```