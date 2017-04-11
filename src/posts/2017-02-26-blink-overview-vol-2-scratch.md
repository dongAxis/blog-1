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
  - InlineTextBox (single "text run" level entity?)

- FloatingObject

# Topology

Document
'-' LayoutView

Node
'-' LayoutObject

LayoutBoxModelObject
'-' PaintLayer

LayoutObject 
'-' ComputedStyle

ComputedStyle
'-' StyleBoxData (as m_box)
'-' etc...

LayoutItem
'-' LayoutObject

LayoutBox
'-' BoxOverflowModel

LayoutView
'-' LayoutState
'-' PaintLayerCompositor (supposedly replaced with PaintArtifactCompositor for SPv2)

LayoutBlock
'-* LayoutObject  (as m_children)

LayoutBlockFlow
'-* InlineFlowBox  (as m_lineBoxes)

LayoutInline
'-*  LayoutObject   (as m_children)
'-*  InlineFlowBox  (as m_lineBoxes)

LayoutText
'-* InlineTextBox (as m_{first,last}TextBox)

InlineFlowBox
'-*  InlineBox (as m_{first,last}Child)

InlineBox
'-'  LayoutObject (as m_lineLayoutItem)

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
'-' PaintLayer (as root layer)	 	 
'-* GraphicsLayer

PaintLayer	 	 
'-' LayoutBoxModelObject
'-* PaintLayer (as children node)
'-' LayoutPoint
'-' CompositedLayerMapping (rare data) (squashed to others or its own)
'-' AncestorDependentCompositingInputs
   '-* PaintLayer (track some special kind of ancestor e.g. opacityAncestorer, transformAncestor, filterAncestor, clipParent)
'-' PaintLayerStackingNode (track z-index ordered nodes)

PaintLayerStackingNode
'-* PaintLayerStackingNode (as posZOrderList)
'-* PaintLayerStackingNode (... neg)

CompositedLayerMapping
'-' PaintLayer
'-* GraphicsLayer (bunch of types, their hierarchy is explained as commemt)
'-' GraphicsLayer (m_squashingLayer)
'-* GraphicsLayerPaintInfo (m_squashedLayers)
    '-' PaintLayer

GraphicsLayer	 	 
'-* GraphicsLayer
'-' GraphicsLayerClient (normally CompositeLayerMapping)
'-' PaintController
'-' WebContentLayer
    '-' WebLayer
        '-' cc::Layer
'-' WebContentLayerClient

GraphicsContext
'-' PaintCanvas (SkCanvas)
'-' PaintController
'-* GraphicsContextState (paint states as stack)
'-' SkMetaData

PaintLayerFragment
'-* Rect (bunch of types of ClipRect and LayoutRect)

PaintLayerPainter (for self-painting PaintLayer)
'-'  PaintLayer

PaintController
'-' DisplayItemList
  '-* DisplayItem
  '-* IntRect (visualRects)

DisplayItem	 	 
'-' DisplayItemClient	 	 
'-' DisplayItem::Type	 	 

---

# Layout entry point

- FrameView::layout =>
  - performPreLayoutTask =>
    - advanceTo(DocumentLifecycle::InPreLayout)
    - Document::mediaQuery...
    - updateStyleAndLayoutTree (see http://wp.hiogawa.net/2017/02/07/blink-overview/)
    - advanceTo(DocumentLifecycle::StyleClean)
  - performLayout =>
    - advanceTo(DocumentLifecycle::InPerformLayout)
    - layoutFromRootObject =>
      - LayoutView::layout =>
        - initialize SubtreeLayoutScope
        - SubtreeLayoutScope::setChildNeedsLayout (for children with size isPercentOrCalc)
        - initialize  LayoutState 
        - layoutContent => LayoutBlock::layout => (see below)
    - advanceTo(DocumentLifecycle::AfterPerformLayout)
  - scheduleOrPerformPostLayoutTasks

- LayoutBlock::layout => LayoutBlockFlow::layoutBlock(false) =>
  - simplifiedLayout (?)
  - updateLogicalWidthAndColumnWidth => ... => LayoutView::layoutSize => FrameView::layoutSize
  - layoutChildren (loop this if something failed it? not in the sense of traversing some tree structure ?) =>
    - setLogicalHeight (?)
    - layoutBlockChildren =>
      - (for each child)
        - (special care for child if it isOutOfFlowPositioned, isFloating, isColumnSpanAll)
        - (but, normally) layoutBlockChild =>
          - computeAndSetBlockDirectionMargin
          - estimateLogicalTopPosition
          - positionAndLayoutOnceIfNeeded =>
            - setLogicalTopForChild
            - LayoutBlock::layout (recursively back to the flow above for this child) => ...
          - determineLogicalLeftPositionForChild
          - setLogicalHeight (add up child's height)
        - handleAfterSideOfBlock =>
          - setLogicalHeight (add up bottom margin)
    - setLogicalHeight (some float things)
  - layoutPositionedObjects
  - updateLayerTransformAfterlayout => 

(for non LayoutView)
- LayoutBlock::updateLogicalWidthAndColumnWidth => LayoutBox::updateLogicalWidth => computeLogicalWidth =>
  - containingBlockLogicalWidthForContent
  - computeMarginsForDirection


Q. why is LayoutView::layout called 5 times for my example?

- WebView initialization => FrameView::layout =>
  - performLayout => LayoutView::layout
  - adjustViewSizeAndLayout => ... => scrollbarExistenceDidChanged => LayoutView::layout
  - Document::layoutUpdated => ... => scrollbarExistenceDidChanged => LayoutView::layout

- TaskQueueManager::DoWork => ... => HTMLParserSchedular::continueParsing => ... => Document::implicitClose => FrameView::layout 
- FrameView::updateAllLifecyclePhases => ... => layout

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

- FrameView::updateAllLifecyclePhases(PaintClean) => updateLifecyclePhasesInternal =>
  -  PaintLayerCompositor::updateIfNeededRecursive => updateIfNeededRecursiveInternal (for each nested frame) =>
    - advanceTo(InCompositingUpdate)
    - updateIfNeeded (see below)
    - advanceTo(DocumentLifecycle::CompositingClean)
  - FrameView::prepaint (? is this only for SPv2)
  - FrameView::paintTree (see below)

- updateIfNeeded
  - CompositingInputsUpdater::update => updateRecursive =>
    - initialize PaintLayer::AncestorDependentCompositingInputs
    - updateRecursive (for each child PaintLayer)
  - CompositingRequirementsUpdater::update => updateRecursive =>
    - updateLayerListsIfNeeded => ... => PaintLayerStackingNode::rebuildZOrderList ...
    - lots of CompositingReason ... (read later)
    - updateRecursive (for each stacked object under this PaintLayer)
    - PaintLayer::setCompositeReason
  - CompositingLayerAssigner::assign => assignLayersToBackingsInternal =>
    - determine "squash"-ability by checking CompositingReason
    - updateSquashingAssignment =>
      - CompositingLayerMapping::updateSquashingLayerAssignment =>
        - Vector<GraphicsLayerPaintInfo>::insert ? (squash into squashingState.mostRecentMapping)
        - PaintLayer::setGroupedMapping ?
    - assignLayersToBackingsInternal (for each stacked object)
  - updateClippingOnCompositorLayers (some root frame layer scroller thing?)
  - GraphicsLayerUpdater::update => updateRecursive =>
    - CompositedLayerMapping::updateGraphicsLayerConfiguration =>
      - updateXXXLayers (e.g. updateSquashingLayers) =>
        - createGraphicsLayer => GraphicsLayer::Create
    - CompositeLayerMapping::updatteGraphicsLayerGeometry =>
      - ... GraphicsLayer::setXXX (e.g. Transform, Position, ...) => WebLayerImpl::setPosition
    - updateRecursive (for each child PaintLayer)
  - GraphicsLayerTreeBuilder::rebuild =>
    - rebuild (for NegativeZOrderChildren)
    - rebuild (for NormalFlowChildren and PositiveZOrderChildren)
    - ? what's up with stuff around GraphicsLayerVector

- FrameView::paintTree => paintGraphicsLayerRecursively =>
  - GraphicsLayer::paint (if drawsContent)  =>
    - paintWithoutCommit =>
      - CompositedLayerMapping::computeInterestRect
      - initialize GraphicsContext
      - CompositedLayerMapping::paintContents => doPaintTask (for its own or for each squashed paint layer) (go below)
    - PaintController::commitNewDisplayItems =>
      - DisplayItemList::appendVisualRect (for each DisplayItem)
      - what's up with "commit" ?
  - paintGraphicsLayerRecursively (for mask layer and each child GraphicsLayer)

- CompositedLayerMapping::doPaintTask =>
  - (non-squashed case) PaintLayerPainter::paintLayerContents =>
    - initialize PaintLayerFragments
    - paintXXXforFragments (e.g. paintBackgroundForFragments) => paintFragmentWithPhase(PaintPhaseSelfBlockBackgroundOnly, ...) =>
      - process PaintInfo, LayoutOffset
      - LayoutObject::paint(PaintInfo, LayoutOffset) (e.g. LayoutBlock::paint) (see below)
    - paintChildren (in terms of zOrderNeg and zOrderPos) =>
      - PaintLayerPainter::paint =>
        - paintLayerWithTransform => paintFragmentByApplyingTransform => paintLayerContentsCompositingAllPhases => paintLayerContents
        - (or directly) paintLayerContentsCompositingAllPhases => paintLayerContents
  - (squashed case)
    - PaintLayerPainter::paint => (see above)

- LayoutBlock::paint => ...

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
  - I guess, this shouldn't be called "compositing". squashing is only for resource saving purpose?
- 2. composite GraphicsLayers ?? who does that ? (impl side compositing ?)

Q. how to see log from TRACE_EVENT0 ?

- see http://www.chromium.org/developers/how-tos/trace-event-profiling-tool

# Recording on Blink

(topology)
LayoutObjectDrawingRecorder
'-' DrawingRecorder
    '-' GraphicsContext
    '-' DisplayItemClient
    '-' DisplayItem::Type

GraphicsContext
'-' SkCanvas
'-' ...

[procedures]

- PaintLayerPainter::paintLayerContents =>
- paintBackgroundForFragments => ... => LayoutView::paint
  - ViewPainter::paint =>
    - LayoutBlock::paintObject => BlockPainter::paintObject =>
      - LayoutView::paintBoxDecorationBackground => ViewPainter::xxx =>
        - create LayoutObjectDrawingRecorder
        - GraphicsContext::fillRect =>
          - GraphicsContextState::fillPaint (or synonym filleFlags)
          - drawRect => SkCanvas::drawRect => onDrawRect => some magics... (TRY_MINIRECORDER and APPEND macro)
- paintChildren(NegativeZOrderChildren) => ... (no children for my example)
- paintForegroundForFragments => ...(same flow as above but phase is now different) =>
  - BlockPainter::paintObject =>
    - BlockFlowPainter::paintContents => BlockPainter::paintContents => LayoutBlock::paintChildren =>
      - BlockPainter::paintChildren => paintChild (for each child LayoutBox) =>
        - LayoutBox::paint (only for non-self-painting child) (actually nothing matched for my example)
- paintChildren(NormalFlowChildren | PositiveZOrderChildren) =>
  - PaintLayerPainter::paint => ... => paintLayerContents =>

[nest level for my example]

- GraphicsLayer::paint => paintWithoutCommit => CLM::paintContents => doPaintTask =>
  - paintLayerContents =>
    - paintBackgroundForFragments => ... => LayoutView::paint => Graphics::drawRect
    - paintChildren(NormalFlow or PosZOrder) => ... =>
      - paintLayerContents =>
        - paintBackgroundForFragments (I missed it again ...)
        - paintForegroundForFragments => ... =>
          LayoutBlock/BlockPainter::paint =>
            - (several paintObject calls with different locally patched paintPhase (localPaintInfo.phase), which leads to different parts in paintObject)
            - LayoutBlock/BlockPainter::paintObject =>
              - paintDecorationBackground, paintMask, etc... (depending on self-painting-ness and paintPhase)
              - BlockFlowPainter/BlockPainter::paintContents => LayoutBlock/BlockPainter::paintChildren =>
                - paintChild (for each child LayoutBox) => LayoutBlock/BlockPainter::paint (repeat above)

Q. what is LayoutUnit ?

for example, in LayoutView::updateLogicalWidth, LayoutUnit ::LayoutUnit(int ) converts value to 6 bit shifted as in kLayoutUnitFractionalBits = 6, which is same as multiplication by 64.
So, if Viewport is 800x600, layoutView's m_frameRect will be 51200x38400

Q. what belongs to Foreground and what belongs to NormalFlowChildren ?

- non-self-painting children will go to some ancestor's Fourground contents
- self-painting children will go to some ancestor's NormalFlowChildren


# frame lifecycle and its entrypoint

- RenderView initialization (see Blink Overview Vol. 1)
  - RenderThreadImpl::CreateView => ... => WebViewImpl::updateAllLifecyclePhase =>
    - PageWidgetDelegate::updateAllLifecyclePhases => ... => FrameView::updateAllLifecyclePhases(PaintClean)
    - content::RenderWidget::didMeaningFullLayout (as WebWidgetClient) =>
      - QueueMessage(new ViewHostMsg_didFirstVisuallyNonEmptyPaint, ...) => must be something ?? maybe not, considering anyway renderer needs impl side compositing.

- * Queued task (how??)
  - ... => TaskQueueManagerDoWork =...=> cc::ProxyMain::BeginMainFrame =>
    cc::LayerTreeHostInProcess::RequestMainFrameUpdate => RenderWidgetCompositor::UpdateLayerTreeHost =>
    RenderWidget::UpdateVisualState => WebViewFrameWidget::updateAllLifecyclePhases => WebViewImpl::xxx => ...

- ui event handler (hit testing) on main thread
  - ... => TaskQueueManagerDoWork => content::MainThreadEventQueue::DispatchSingleEvent => DispatchInFlightEvent =>
    InputEventFilter::HandleEventOnMainThread => ChildThreadImpl::OnMessageReceived => MessageRouter::xxx =>
    ChildThreadImpl::ChildThreadMessageRouter::RouteMessage => IPC::MessageRouter::xxx =>
    RenderViewImpl::OnMessageReceived => IPC_MESSAGE_HANDLER(InputMsg_HandleInputEvent, OnHandleInputEvent) => (some IPC magic) =>
    RenderWidget::OnHandleInputEvent => RenderWidgetInputHandler::HandleInputEvent => WebViewFrameWidget::handleInputEvent =>
    WebViewImpl::handleInputEvent => PageWidgetDelegate::xxx => e.g. handleMouseMove =>
    EventHandler::handleMouseMoveEvent => handleMouseMoveOrLeaveEvent => EventHandlingUtil::performMouseEventHitTest =>
    Document::xxx => LayoutViewItem::hitTest => LayoutView::histTest => ... follow until you find Element to dispatch event ??
    

  - ?? => LayoutView::hitTest => ?? => FrameView::updateAllLifecyclePhases(CompositingClean) =>

- how about impl thread ??
  - does this happen on WebViewImpl::handleInputEvent, I guess ??
```