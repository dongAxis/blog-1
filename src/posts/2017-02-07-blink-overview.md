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
'-* RenderFrameImpl (as base::ObserverList<RenderFrameImpl> render_frames_)
'-' ScreenInfo
'-' WebWidget

RenderViewImpl
'-' RenderFrameImpl
'-' WebFrameWidget
'-' WebView

RenderFrameImpl
'-' RenderViewImpl
'-' RenderWidget (when it's local root)
'-' WebLocalFrame


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
'-' WebLayer
'-' WebLayerTreeView

WebFrameWidget

WebFrameWidgetBase

WebViewFrameWidget
'-' WebWidgetClient
'-' WebLocalFrameImpl
'-' WebViewImpl

WebFrameWidgetImpl
'-' WebWidgetClient
'-' WebLocalFrameImpl
'-' WebLayer
'-' WebLayerTreeView

(frame things)

WebFrame
'-' WebFrame (as m_opener)
'-' WebFrame (as m_parent)
'-* WebFrame (as m_{first,last}Child)

WebLocalFrameImpl
'-' WebFrameWidgetBase (only when frame is root frame)
'-' WebDevToolsFrontendImpl
'-' WebDevToolsAgentImpl
'-' WebFrameClient (impl is RenderFrameImpl)
'-' FrameLoaderClientImpl
'-' LocalFrame

(internal frame things)

Widget
'-' FrameRect
'-' Widget (m_parent)

FrameView
'-* Widget (as ChildrenWidgetSet m_children)
'-' LocalFrame
'-' LayoutSize

Frame
'-' DomWindow

LocalFrame
'-' FrameView
'-' FrameLoader
'-' ScriptController

Page
'-' Frame

(loaders)
FrameLoader
'-' DocumentLoader
'-' LocalFrame

DocumentLoader
'-' RawResource (m_mainResourse)
'-' ResourceFetcher
'-' LocalFrame
'-' DocumentWriter
    '-' DocumentParser
    '-' Document
'-' Resource{Request,Response} (how does this relate to mainresourse)

ResourceFetcher
'-* ResourceLoader (as m_loaders or m_nonBlockingLoaders)

ResourceLoader
'-' WebURLLoader
'-' Resource
'-' ResourceFetcher

Resource
'-* ResourceClient (as m_clients{,AwaitingCallback}, m_finishedClients)
'-' ResourceLoader
'-' Resource{Request,Response}

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
'-' Frame
'-' Location

LocalDomWindow
'-' Document

Document
'-' DocumentParser
'-' ResourceFetcher
'-' LocalFrame
'-' LayoutView

LayoutView
'-' FrameView

HTMLDocumentParser
'-' HTMLTreeBuilder
    '-' HTMLConstructionSite
        '-' HTMLDocument
'-' HTMLInputStream

Node
'-' LayoutObject

LayoutObject
'-' ComputedStyle
```

# Some important steps

```
# Navigation and Resource loading

- (some IPC ?) =>
  - WebLocalFrame::LoadRequest => load => FrameLoader::load => startLoad =>
    - FrameLoaderClientImpl::createDocumentLoader
    - DocumentLoader::startLoadingMainResource =>
      - RawResource::fetchMainResource => ResourceFetcher::requestResource =>
        - createResourceForLoading => RawResourceFactory::create
        - ResourceFetcher::startLoad =>
          - ResourceLoader::create
          - ResourceLoader::start =>
            - RendererBlinkPlatformImpl::createURLLoader  (yay! finally reached platform implementation!)
            - WebURLLoaderImpl::loadAsynchronously => WebURLLoaderImpl::Context::Start => (some IPC on ResourceDispachter ...)
      - RawResource.addClient(DocumentLoader)

# Resource reception and DOM construction

HTMLDocumentParser spec: https://html.spec.whatwg.org/multipage/syntax.html

[Incremental]

- (... some IPC from ResourceDispatcher) => WebURLLoaderImpl::Context::OnReceivedResponse => 
  - ResourceLoader::didReceiveData => RawResource::appendData =>
    - DocumentLoader::dataReceived (as RawResourseClient) => processData => commitData =>
      - ensureWriter => createWriterFor => DocumentWriter::create => Document::createParser => HTMLDocumentParser::create
      - DocumentWriter::addData =>
        - HTMLDocumentParser::appendBytes (as DocumentParser) => DocodedDataDocumentParser::appendBytes => updateDocument =>
          HTMLDocumentParser::append => pumpTokenizer => constructTreeFromHTMLToken =>
          HTMLTreeBuilder::constructTree => processToken => (e.g. processStartTagForInBody) =>
          HTMLConstructionSite::insertHTMLElement =>
          - createHTMLElement => HTMLElementFactory::createHTMLElement (=> e.g. HTMLDivElement::Create) 
          - attachLater => (queueTask --> executeQueuedTasks) => executeTask => executeInsertTask => insert => ContainerNode::parserAppendChild

[Completion]

- (some platform IPC ...) => WebURLLoaderImpl::Context::OnCompletedRequest => ResourceLoader::didFinishLoading =>
  ResourceFetcher::handlerLoaderFinish => Resource::finish => CheckNotify =>
  DocumentLoader::notifyFinished => finishedWriting => endWriting => DocumentWriter::end =>
  HTMLDocumentParser::finish => attemptToEnd => prepareToStopParsing => attemptToRunDeferredScriptsAndEnd => end =>
  HTMLTreeBuilder::finished => HTMLConstructionSite::finishedParsing => Document::finishedParsing =>
  - dispatchEvent (with DOMContentLoaded)  
  - FrameLoader::finishedParsing => checkCompleted =>
    - Document::implicitClose =>
      - updateStyleAndLayoutTree =>
        - updateStyle => (go to "Style Calculation" below)
        - notifyLayoutTreeOfSubtreeChanges =>
          - advanceTo(DocumentLifecycle::InLayoutSubtreeChange)
          - LayoutItem::handleSubtreeModifications => LayoutObject::handleSubtreeModifications (go to "layout tree change" below)
          - advanceTo(DocumentLifecycle::LayoutSubtreeChangeClean)
      - FrameView::layout => performLayout => layoutFromRootObject => LayoutView::layout => (go to "Layout" below)

# CSS (Style calculation, Layout tree construction)

(Topology)
Document
'-' StyleEngine
'-' StyleSheetList
'-' LayoutView

Node
'-' LayoutObject (this is rare data)

LayoutObject 
'-' ComputedStyle

LayoutItem '-' LayoutObject

StyleEnine
'-' StyleResolver

ElementResolveContext
'-' Element (m_element)
'-' ContainerNode (m_parentNode)
'-' ComputedStyle (m_rootElementStyle)

(Procedures)

- Document::updateStyle =>
  - StyleResolver::styleForDocument => ComputedStyle::create()
  - ensureStyleResolver
  - inheritHtmlAndBodyElementStyles (some root element and body element quirks) =>
    - StyleResolver::styleForElement (for root and body) (see below for detail)
  - Element::recalcStyle (from root) (see below for detail)
  - FrameView::recalcOverflowAfterStyleChange => (some viewport or root element thing? forget it for now.)

- StyleResolver::styleForElement (this returns ComputedStyle)
  - initialize ElementResolveContext and StyleResolverState
  - calculateBaseComputedStyle
  - inheritFrom or initialStyleForElement or ComputedStyle::create
  - ensureUAStyleForElement
  - initialize ElementRuleCollector
  - matchAllRules =>
    - StyleResolver::matchUARules => matchRuleSet =>
      - ElementRuleCollector::collectMatchingRules => collectMatchingRulesForList (for cases by ID, tag name, etc..) => didMatchRule
    - (apply inline style from html attribute e.g. Element::presentationAttributeStyle)
    - matchAuthorRules =>
      - matchHostRules (some shadow dom styling is happening ? let's forget it for now...)
      - matchScopedRules =>
        - initialize ScopedStyleResolver
        - matchElementScopeRules => ScopedStyleResolver::collectMatchingAuthorRules => collectMatchingRules (same as above (matchUARules))
  - adjustComputedStyle =>StyleAduster::adjustComputedStyle =>
    - adjustStyleForHTMLElement (some element's tag based style change)
    - etc... (looks like a big deal though...)

- Element::recalcStyle =>
  - recalcOwnStyle =>
    - propagateInheritedProperties or styleForLayoutObject (=> originalStyleForLayoutObject => StyleResolver::styleForElement)
    - ComputedStyle::stylePropagationDiff (will return Reattach if Element (Node) didn't have LayoutObject yet)
    - rebuildLayoutTree => reattachLayoutTree => attachLayoutTree =>
      - LayoutTreeBuilderForElement::createLayoutObjectIfNeeded => createLayoutObject =>
        - Element::createLayoutObject => LayoutObject::createObject => (new LayoutXXX depending on arguments, Element and ComputedStyle)
        - Node::setLayoutObject
      - Element::createPseudoElementIfNeeded =>
        - StyleResolver::createPseudoElementIfNeeded => (animation things considered ??)
        - PseudoElement::attachLayoutTree => TextContentData::createLayoutObject => new LayoutTextFragment
    - LayoutObject::setStyle => LayoutBoxModelObject::StyleDidChange =>
      - createLayer => ... WTF and base magic ... => new PaintLayer
      - Layout invalidation, Paint invalidatiaon and more
  - recalcDescendantStyles => Text::recalcTextStyle or Element::recalcStyle for each child
  - updatePseudoElement (recalcStyle for PseudoElement)

# Layout
??

# Drawing (paint, composite, display)
??

# Event (handler registration, event dispatching)

- IPC::ChannelProxy::Context::OnDispatchMessage => ChildThreadImpl::OnMessageReceived => IPC::MessageRouter::xxx =>
  ChildThreadImpl::ChildThreadMessageRouter::RouteMessage => IPC::MessageRoute::xxx =>
  RenderViewImpl::OnMessageReceived => RenderWidget::xxx =>
  IPC_MESSAGE_HANDLER(InputMsg_HandleInputEvent, OnHandleInputEvent) => ... (some magic) =>
  RenderWidget::OnHandleInputEvent => RenderWidgetInputHandler::HandleInputEvent => WebViewFrameWidget::xxx => WebViewImpl::xxx =>
  PageWidgetDelegate::xxx => (e.g. handleMouseMove) => EventHandler::handleMouseMoveEvent => handleMouseMoveEventOrLeaveEvent =>
  EventHandlingUtil::performMouseEventHitTest => Document::xxx => LayoutView::hitTest =>
  - FrameView::updateLifecycleToCompositingCleanPlusScrolling
  - ???
 
# Javascript execution
??

# Renderer process initialization
- main => ContentMain => ContentMainRunnerImpl::Run => RunZygote => RendererMain =>
  - SkGraphics::Init()
  - HandleRendererErrorTestParameters => ChildProcess::WaitForDebugger => pause
  - new base::MessageLoop()
  - blink::scheduler::RendererScheduler::Create
  - RenderProcessImpl render_process (+2 threads via ChildProcess)
  - RenderThreadImpl::Create
  - base::RunLoop().Run()

# RenderView initialization
- (IPC) => RenderThreadImpl::CreateView => RenderViewImpl::Create => Initialize =>
  - WebView::Create
  - RenderFrameImpl::CreateMainFrame
  - RenderViewImpl::OnResize => RenderWidget::OnResize => Resize => RenderViewImpl::ResizeWidget =>
    WebViewImpl::resizeWithBrowserControls => resizeViewWhileAnchored => updateAllLifecyclePhases =>
    PageWidgetDelegate::updateAllLifecyclePhases => PageAnimator::updateAllLifecyclePhases =>
    FrameView::updateAllLifecyclePhases(PaintClean) => updateLifecyclePhasesInternal =>
    - ... => FrameView::layout
    - ... => PaintLayerCompositor::updateIfNeeded 
    - ? ...
  - ?

# Devtool
?
```