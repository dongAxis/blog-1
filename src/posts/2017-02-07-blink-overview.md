<!--
{
  "title": "Blink Overview (Vol. 1)",
  "date": "2017-02-07T07:41:28.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

# Classes

```
#### Content #####

## Inheritance

- RenderWidgetInputHandlerDelegate --\ 
- RenderWidgetCompositorDelegate   --- RenderWidget
- WebWidgetClient                  --/

- RenderView    --\
- RenderWidget  --- RenderViewImpl (DEPRECATING)
- WebViewClient --/

- RenderFrame    --\
- mojom::Frame   --- RenderFrameImpl  
- WebFrameClient --/


## Topology

RenderWidget
&#039;-* RenderFrameImpl (as base::ObserverList&lt;RenderFrameImpl&gt; render_frames_)
&#039;-&#039; ScreenInfo
&#039;-&#039; WebWidget

RenderViewImpl
&#039;-&#039; RenderFrameImpl
&#039;-&#039; WebFrameWidget
&#039;-&#039; WebView

RenderFrameImpl
&#039;-&#039; RenderViewImpl
&#039;-&#039; RenderWidget (when it&#039;s local root)
&#039;-&#039; WebLocalFrame


#### Blink ####

## Inheritance

- WebWidget
  - WebView
    - WebViewImpl
  - WebFrameWidget
    - WebFrameWidgetBase
      - WebFrameWidgetImpl
      - WebViewFrameWidget

- WebLayer
  - WebLayerImpl (in cc/blink)
- WebLayerTreeView
  - RenderWidgetCompositor (in content/renderer/gpu)

- WebFrame
  - WebLocalFrame - WebLocalFrameImpl
  - WebRemoteFrame - WebRemoteFrameImpl

- WebFrameClient
  - RenderFrameImpl (content)

- Widget
  - FrameView
  - Scrollbar
  - PluginView

- Frame
  - LocalFrame
  - RemoteFrame

- ResourceClient
  - RawResourceClient
    - DocumentLoader

- Resource
  - RawResource

- WebURLLoaderClient (notified when platform loads resource)
  - ResourceLoader
    - RawResourceLoader

## Topology

(widget/view things)

WebWidget

WebViewImpl
&#039;-&#039; WebLayer
&#039;-&#039; WebLayerTreeView

WebFrameWidget

WebFrameWidgetBase

WebViewFrameWidget
&#039;-&#039; WebWidgetClient
&#039;-&#039; WebLocalFrameImpl
&#039;-&#039; WebViewImpl

WebFrameWidgetImpl
&#039;-&#039; WebWidgetClient
&#039;-&#039; WebLocalFrameImpl
&#039;-&#039; WebLayer
&#039;-&#039; WebLayerTreeView

(frame things)

WebFrame
&#039;-&#039; WebFrame (as m_opener)
&#039;-&#039; WebFrame (as m_parent)
&#039;-* WebFrame (as m_{first,last}Child)

WebLocalFrameImpl
&#039;-&#039; WebFrameWidgetBase (only when frame is root frame)
&#039;-&#039; WebDevToolsFrontendImpl
&#039;-&#039; WebDevToolsAgentImpl
&#039;-&#039; WebFrameClient (impl is RenderFrameImpl)
&#039;-&#039; FrameLoaderClientImpl
&#039;-&#039; LocalFrame

(internal frame things)

Widget
&#039;-&#039; FrameRect
&#039;-&#039; Widget (m_parent)

FrameView
&#039;-* Widget (as ChildrenWidgetSet m_children)
&#039;-&#039; LocalFrame
&#039;-&#039; LayoutSize

Frame
&#039;-&#039; DomWindow

LocalFrame
&#039;-&#039; FrameView
&#039;-&#039; FrameLoader
&#039;-&#039; ScriptController

Page
&#039;-&#039; Frame

(loaders)
FrameLoader
&#039;-&#039; DocumentLoader
&#039;-&#039; LocalFrame

DocumentLoader
&#039;-&#039; RawResource (m_mainResourse)
&#039;-&#039; ResourceFetcher
&#039;-&#039; LocalFrame
&#039;-&#039; DocumentWriter
    &#039;-&#039; DocumentParser
    &#039;-&#039; Document
&#039;-&#039; Resource{Request,Response} (how does this relate to mainresourse)

ResourceFetcher
&#039;-* ResourceLoader (as m_loaders or m_nonBlockingLoaders)

ResourceLoader
&#039;-&#039; WebURLLoader
&#039;-&#039; Resource
&#039;-&#039; ResourceFetcher

Resource
&#039;-* ResourceClient (as m_clients{,AwaitingCallback}, m_finishedClients)
&#039;-&#039; ResourceLoader
&#039;-&#039; Resource{Request,Response}

#### Furthor pieces in Blink ###

## Inheritance

- DomWindow
  - LocalDomWindow

- DocumentParser
  - DecodedDocumentParser
    - HTMLDocumentParser

- EventTarget
  - Node
    - ContainerNode
      - Element
        - HTMLEelment
      - Document
        - HTMLDocument

## Topology

DomWindow
&#039;-&#039; Frame
&#039;-&#039; Location

LocalDomWindow
&#039;-&#039; Document

Document
&#039;-&#039; DocumentParser
&#039;-&#039; ResourceFetcher
&#039;-&#039; LocalFrame
&#039;-&#039; LayoutView

LayoutView
&#039;-&#039; FrameView

HTMLDocumentParser
&#039;-&#039; HTMLTreeBuilder
    &#039;-&#039; HTMLConstructionSite
        &#039;-&#039; HTMLDocument
&#039;-&#039; HTMLInputStream

Node
&#039;-&#039; LayoutObject

LayoutObject
&#039;-&#039; ComputedStyle
```

# Some important steps

```
# Navigation and Resource loading

- (some IPC ?) =&gt;
  - WebLocalFrame::LoadRequest =&gt; load =&gt; FrameLoader::load =&gt; startLoad =&gt;
    - FrameLoaderClientImpl::createDocumentLoader
    - DocumentLoader::startLoadingMainResource =&gt;
      - RawResource::fetchMainResource =&gt; ResourceFetcher::requestResource =&gt;
        - createResourceForLoading =&gt; RawResourceFactory::create
        - ResourceFetcher::startLoad =&gt;
          - ResourceLoader::create
          - ResourceLoader::start =&gt;
            - RendererBlinkPlatformImpl::createURLLoader  (yay! finally reached platform implementation!)
            - WebURLLoaderImpl::loadAsynchronously =&gt; WebURLLoaderImpl::Context::Start =&gt; (some IPC on ResourceDispachter ...)
      - RawResource.addClient(DocumentLoader)

# Resource reception and DOM construction

HTMLDocumentParser spec: https://html.spec.whatwg.org/multipage/syntax.html

[Incremental]

- (... some IPC from ResourceDispatcher) =&gt; WebURLLoaderImpl::Context::OnReceivedResponse =&gt; 
  - ResourceLoader::didReceiveData =&gt; RawResource::appendData =&gt;
    - DocumentLoader::dataReceived (as RawResourseClient) =&gt; processData =&gt; commitData =&gt;
      - ensureWriter =&gt; createWriterFor =&gt; DocumentWriter::create =&gt; Document::createParser =&gt; HTMLDocumentParser::create
      - DocumentWriter::addData =&gt;
        - HTMLDocumentParser::appendBytes (as DocumentParser) =&gt; DocodedDataDocumentParser::appendBytes =&gt; updateDocument =&gt;
          HTMLDocumentParser::append =&gt; pumpTokenizer =&gt; constructTreeFromHTMLToken =&gt;
          HTMLTreeBuilder::constructTree =&gt; processToken =&gt; (e.g. processStartTagForInBody) =&gt;
          HTMLConstructionSite::insertHTMLElement =&gt;
          - createHTMLElement =&gt; HTMLElementFactory::createHTMLElement (=&gt; e.g. HTMLDivElement::Create) 
          - attachLater =&gt; (queueTask --&gt; executeQueuedTasks) =&gt; executeTask =&gt; executeInsertTask =&gt; insert =&gt; ContainerNode::parserAppendChild

[Completion]

- (some platform IPC ...) =&gt; WebURLLoaderImpl::Context::OnCompletedRequest =&gt; ResourceLoader::didFinishLoading =&gt;
  ResourceFetcher::handlerLoaderFinish =&gt; Resource::finish =&gt; CheckNotify =&gt;
  DocumentLoader::notifyFinished =&gt; finishedWriting =&gt; endWriting =&gt; DocumentWriter::end =&gt;
  HTMLDocumentParser::finish =&gt; attemptToEnd =&gt; prepareToStopParsing =&gt; attemptToRunDeferredScriptsAndEnd =&gt; end =&gt;
  HTMLTreeBuilder::finished =&gt; HTMLConstructionSite::finishedParsing =&gt; Document::finishedParsing =&gt;
  - dispatchEvent (with DOMContentLoaded)  
  - FrameLoader::finishedParsing =&gt; checkCompleted =&gt;
    - Document::implicitClose =&gt;
      - updateStyleAndLayoutTree =&gt;
        - updateStyle =&gt; (go to &quot;Style Calculation&quot; below)
        - notifyLayoutTreeOfSubtreeChanges =&gt;
          - advanceTo(DocumentLifecycle::InLayoutSubtreeChange)
          - LayoutItem::handleSubtreeModifications =&gt; LayoutObject::handleSubtreeModifications (go to &quot;layout tree change&quot; below)
          - advanceTo(DocumentLifecycle::LayoutSubtreeChangeClean)
      - FrameView::layout =&gt; performLayout =&gt; layoutFromRootObject =&gt; LayoutView::layout =&gt; (go to &quot;Layout&quot; below)

# CSS (Style calculation, Layout tree construction)

(Topology)
Document
&#039;-&#039; StyleEngine
&#039;-&#039; StyleSheetList
&#039;-&#039; LayoutView

Node
&#039;-&#039; LayoutObject (this is rare data)

LayoutObject 
&#039;-&#039; ComputedStyle

LayoutItem &#039;-&#039; LayoutObject

StyleEnine
&#039;-&#039; StyleResolver

ElementResolveContext
&#039;-&#039; Element (m_element)
&#039;-&#039; ContainerNode (m_parentNode)
&#039;-&#039; ComputedStyle (m_rootElementStyle)

(Procedures)

- Document::updateStyle =&gt;
  - StyleResolver::styleForDocument =&gt; ComputedStyle::create()
  - ensureStyleResolver
  - inheritHtmlAndBodyElementStyles (some root element and body element quirks) =&gt;
    - StyleResolver::styleForElement (for root and body) (see below for detail)
  - Element::recalcStyle (from root) (see below for detail)
  - FrameView::recalcOverflowAfterStyleChange =&gt; (some viewport or root element thing? forget it for now.)

- StyleResolver::styleForElement (this returns ComputedStyle)
  - initialize ElementResolveContext and StyleResolverState
  - calculateBaseComputedStyle
  - inheritFrom or initialStyleForElement or ComputedStyle::create
  - ensureUAStyleForElement
  - initialize ElementRuleCollector
  - matchAllRules =&gt;
    - StyleResolver::matchUARules =&gt; matchRuleSet =&gt;
      - ElementRuleCollector::collectMatchingRules =&gt; collectMatchingRulesForList (for cases by ID, tag name, etc..) =&gt; didMatchRule
    - (apply inline style from html attribute e.g. Element::presentationAttributeStyle)
    - matchAuthorRules =&gt;
      - matchHostRules (some shadow dom styling is happening ? let&#039;s forget it for now...)
      - matchScopedRules =&gt;
        - initialize ScopedStyleResolver
        - matchElementScopeRules =&gt; ScopedStyleResolver::collectMatchingAuthorRules =&gt; collectMatchingRules (same as above (matchUARules))
  - adjustComputedStyle =&gt;StyleAduster::adjustComputedStyle =&gt;
    - adjustStyleForHTMLElement (some element&#039;s tag based style change)
    - etc... (looks like a big deal though...)

- Element::recalcStyle =&gt;
  - recalcOwnStyle =&gt;
    - propagateInheritedProperties or styleForLayoutObject (=&gt; originalStyleForLayoutObject =&gt; StyleResolver::styleForElement)
    - ComputedStyle::stylePropagationDiff (will return Reattach if Element (Node) didn&#039;t have LayoutObject yet)
    - rebuildLayoutTree =&gt; reattachLayoutTree =&gt; attachLayoutTree =&gt;
      - LayoutTreeBuilderForElement::createLayoutObjectIfNeeded =&gt; createLayoutObject =&gt;
        - Element::createLayoutObject =&gt; LayoutObject::createObject =&gt; (new LayoutXXX depending on arguments, Element and ComputedStyle)
        - Node::setLayoutObject
      - Element::createPseudoElementIfNeeded =&gt;
        - StyleResolver::createPseudoElementIfNeeded =&gt; (animation things considered ??)
        - PseudoElement::attachLayoutTree =&gt; TextContentData::createLayoutObject =&gt; new LayoutTextFragment
    - LayoutObject::setStyle =&gt; LayoutBoxModelObject::StyleDidChange =&gt;
      - createLayer =&gt; ... WTF and base magic ... =&gt; new PaintLayer
      - Layout invalidation, Paint invalidatiaon and more
  - recalcDescendantStyles =&gt; Text::recalcTextStyle or Element::recalcStyle for each child
  - updatePseudoElement (recalcStyle for PseudoElement)

# Layout
??

# Drawing (paint, composite, display)
??

# Event (handler registration, event dispatching)

- IPC::ChannelProxy::Context::OnDispatchMessage =&gt; ChildThreadImpl::OnMessageReceived =&gt; IPC::MessageRouter::xxx =&gt;
  ChildThreadImpl::ChildThreadMessageRouter::RouteMessage =&gt; IPC::MessageRoute::xxx =&gt;
  RenderViewImpl::OnMessageReceived =&gt; RenderWidget::xxx =&gt;
  IPC_MESSAGE_HANDLER(InputMsg_HandleInputEvent, OnHandleInputEvent) =&gt; ... (some magic) =&gt;
  RenderWidget::OnHandleInputEvent =&gt; RenderWidgetInputHandler::HandleInputEvent =&gt; WebViewFrameWidget::xxx =&gt; WebViewImpl::xxx =&gt;
  PageWidgetDelegate::xxx =&gt; (e.g. handleMouseMove) =&gt; EventHandler::handleMouseMoveEvent =&gt; handleMouseMoveEventOrLeaveEvent =&gt;
  EventHandlingUtil::performMouseEventHitTest =&gt; Document::xxx =&gt; LayoutView::hitTest =&gt;
  - FrameView::updateLifecycleToCompositingCleanPlusScrolling
  - ???
 
# Javascript execution
??

# Renderer process initialization
- main =&gt; ContentMain =&gt; ContentMainRunnerImpl::Run =&gt; RunZygote =&gt; RendererMain =&gt;
  - SkGraphics::Init()
  - HandleRendererErrorTestParameters =&gt; ChildProcess::WaitForDebugger =&gt; pause
  - new base::MessageLoop()
  - blink::scheduler::RendererScheduler::Create
  - RenderProcessImpl render_process (+2 threads via ChildProcess)
  - RenderThreadImpl::Create
  - base::RunLoop().Run()

# RenderView initialization
- (IPC) =&gt; RenderThreadImpl::CreateView =&gt; RenderViewImpl::Create =&gt; Initialize =&gt;
  - WebView::Create
  - RenderFrameImpl::CreateMainFrame
  - RenderViewImpl::OnResize =&gt; RenderWidget::OnResize =&gt; Resize =&gt; RenderViewImpl::ResizeWidget =&gt;
    WebViewImpl::resizeWithBrowserControls =&gt; resizeViewWhileAnchored =&gt; updateAllLifecyclePhases =&gt;
    PageWidgetDelegate::updateAllLifecyclePhases =&gt; PageAnimator::updateAllLifecyclePhases =&gt;
    FrameView::updateAllLifecyclePhases(PaintClean) =&gt; updateLifecyclePhasesInternal =&gt;
    - ... =&gt; FrameView::layout
    - ... =&gt; PaintLayerCompositor::updateIfNeeded 
    - ? ...
  - ?

# Devtool
?
```