<!--
{
  "title": "React Overview",
  "date": "2017-02-22T11:05:42.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

# ReactDOM.render main path

```
- ReactDOM.render =&gt; ReactMount.render =&gt; ... =&gt; ReactMount._renderNewRootComponent =&gt;
  - instantiateReactComponent =&gt; ... =&gt; ReactCompositeComponent.construct (or ReactHostComponent.createInternalComponent)
  - ReactDefaultBatchingStrategy.batchedUpdates (as ReactUpdates via injection) =&gt; ... =&gt;
    - ReactMount.mountComponentIntoNode =&gt;
      - ReactReconciler.mountComponent =&gt; (go below)
      - ReactMount._mountImageIntoNode =&gt; DOMLazyTree.insertTreeBefore =&gt; setInnerHTML
  - (after finished transaction.perform callback) this.reactMountReady.notifyAll =&gt; run all queued callbacks

[CompositeComponent case]
- ReactReconciler.mountComponent =&gt;
  - ReactCompositeComponent.mountComponent =&gt;
    - _constructComponent =&gt; ... =&gt; new Component
    - call componentWillMount with possibly followed by setState
    - performInitialMount =&gt;
      - _renderValidatedComponent =&gt; Component.prototype.render (to get child element)
      - instantiateReactComponent (recursive call for child element)
      - ReactReconciler.mountComponent (recursive call for child element)
    - enqueue componentDidMount to getReactMountReady queue
  - enqueue ReactRef.attachRefs to getReactMountReady queue

[HostComponent case (e.g. &quot;div&quot;)]
- ReactReconciler.mountComponent =&gt;
  - ReactDomComponent.mountComponent =&gt;
    - document.createElement
    - _updateDOMProperties =&gt;
      - ensureListeningTo =&gt; listenTo =&gt;  ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent =&gt;
        ReactEventListener.trapBubbledEvent =&gt; EventListener.listen (from fbjs) =&gt; addEventListener
      - DOMPropertyOperations.setValueForProperty
      - CSSPropertyOperations.setValueForStyles
    - DOMLazyTree
    - _createInitialChildren =&gt; ReactMultiChild.mountChildren =&gt; (recursively) instantiation and mountComponent ...
```

# Some basic parts

```
- isomorphic/
  - classic/element/ReactElement
    - createElement
  - modern/ReactBaseClasses
    - ReactComponent.prototype.setState

- renderer/shared/stack/reconciler/
  - instantiateReactComponent
  - ReactCompositeComponent
    - mountComponent (update, unmount)
  - ReactMultiChild (mixin for nesting element)

- renderer/dom/stack/client/
  - ReactDOMComponent (injected as GenericComponentClass)
    - mountComponent (update, unmount)
  - ReactMount (only being dom platform entrypoint)
```

# TODO

- update/unmount process
- transaction callback queue in detail
- stack reconciler algorithm in detail

# Reference

- https://facebook.github.io/react/contributing/codebase-overview.html