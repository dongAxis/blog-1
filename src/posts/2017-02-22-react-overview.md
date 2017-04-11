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
- ReactDOM.render => ReactMount.render => ... => ReactMount._renderNewRootComponent =>
  - instantiateReactComponent => ... => ReactCompositeComponent.construct (or ReactHostComponent.createInternalComponent)
  - ReactDefaultBatchingStrategy.batchedUpdates (as ReactUpdates via injection) => ... =>
    - ReactMount.mountComponentIntoNode =>
      - ReactReconciler.mountComponent => (go below)
      - ReactMount._mountImageIntoNode => DOMLazyTree.insertTreeBefore => setInnerHTML
  - (after finished transaction.perform callback) this.reactMountReady.notifyAll => run all queued callbacks

[CompositeComponent case]
- ReactReconciler.mountComponent =>
  - ReactCompositeComponent.mountComponent =>
    - _constructComponent => ... => new Component
    - call componentWillMount with possibly followed by setState
    - performInitialMount =>
      - _renderValidatedComponent => Component.prototype.render (to get child element)
      - instantiateReactComponent (recursive call for child element)
      - ReactReconciler.mountComponent (recursive call for child element)
    - enqueue componentDidMount to getReactMountReady queue
  - enqueue ReactRef.attachRefs to getReactMountReady queue

[HostComponent case (e.g. "div")]
- ReactReconciler.mountComponent =>
  - ReactDomComponent.mountComponent =>
    - document.createElement
    - _updateDOMProperties =>
      - ensureListeningTo => listenTo =>  ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent =>
        ReactEventListener.trapBubbledEvent => EventListener.listen (from fbjs) => addEventListener
      - DOMPropertyOperations.setValueForProperty
      - CSSPropertyOperations.setValueForStyles
    - DOMLazyTree
    - _createInitialChildren => ReactMultiChild.mountChildren => (recursively) instantiation and mountComponent ...
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