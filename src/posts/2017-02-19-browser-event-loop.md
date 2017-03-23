<!--
{
  "title": "Browser Event Loop",
  "date": "2017-02-19T01:49:56.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- Assumption
  - forget worker (only care browser context)
  - forget nested document (only have root browser context)

- finished parsing (after you got EOF)
  - execute "scripts that will execute when the document has finished parsing" (a.k.a. defer)
  - fire DOMContentLoaded on Document
  - execute "scripts that will execute as soon as possible"  (a.k.a. async?)
  - fire load on Window

- Browser context event loop
  - execution paradigms:
    - https://html.spec.whatwg.org/multipage/infrastructure.html#in-parallel
      - e.g. setTimeout:  https://html.spec.whatwg.org/multipage/webappapis.html#timer-initialisation-steps
    - https://html.spec.whatwg.org/multipage/infrastructure.html#immediately
      - e.g. https://html.spec.whatwg.org/multipage/scripting.html#prepare-a-script
    - asynchronous "complete" algorithms (after "return")
      - e.g. https://html.spec.whatwg.org/multipage/webappapis.html#fetching-scripts
  - essentially, "event loop" runs below for each loop:
    - pick a task
    - run a task
    - "Update the rendering"
      - fire some special events (e.g. viewport resize)
      - run some special callback (e.g. requestAnimationFrame)
      - style calc, layout, paint ...
  - kinds of tasks and when it's pushed to queue:
    - resource fetching
      - Q. how css resource fetching and rendering interleave ?
        - or when first "Update the rendering" really starts ?
      - Q. how special initial document loading is ?
        - https://html.spec.whatwg.org/multipage/browsers.html#read-html
    - load HTML: https://html.spec.whatwg.org/multipage/browsers.html#read-html
      - Q. is "end" only for initial document load ? https://html.spec.whatwg.org/multipage/syntax.html#the-end
      - from https://html.spec.whatwg.org/multipage/syntax.html#tree-construction
        - "This specification does not define when an interactive user agent has to render the Document so that it is available to the user, or when it has to begin accepting user input."
        - so you mean, "event loop" including "Update the rendering" above is not really starting until implementation says so.
      - script execution during document tree construction: https://html.spec.whatwg.org/multipage/syntax.html#scriptEndTag
        - script end tag => prepare script =>
          - (src) ... depends on async and defer attributes
          - (otherwise) "immediately" execute a script block => run a classic script => (go ecma semantics e.g. ParseScript and ScriptEvaluation) 
        - UA will "delay the load event" until script is ready.
      - https://html.spec.whatwg.org/multipage/syntax.html#the-end:
        - Spin the event loop until there is nothing that delays the load event in the Document.
        - Q. how does it relate to Document#createElement, Parent#appendChild api ?
          - hidden "become connected event" triggers preparing script. see https://html.spec.whatwg.org/multipage/scripting.html#script-processing-model
    - load script: 
      - https://html.spec.whatwg.org/multipage/scripting.html#dom-script-text
    - (ui) event firing, dispatching handlers execution
      - all matched handlers for "single event" are executed as a single task.
      - Q. how UA initiates hit-testing and queue event firing task is out of spec ?
        - how about this ? https://html.spec.whatwg.org/multipage/interaction.html#activation
      - https://dom.spec.whatwg.org/#concept-event-dispatch
  - https://html.spec.whatwg.org/multipage/webappapis.html#event-loop-processing-model
  - https://wicg.github.io/ResizeObserver/#integrations
  - https://w3c.github.io/uievents/#dom-event-architecture
  - interesting semantics for setTimeout
    - https://html.spec.whatwg.org/multipage/webappapis.html#timer-initialisation-steps
    - wait for timer to finish `in parallel` to mail loop and queue callback task after that.

- Q. how image resouce fetching comes into event loop ?
  - https://html.spec.whatwg.org/#images-processing-model

- Q. fetch
  - https://fetch.spec.whatwg.org/#concept-fetch
  - tasks fetch algorithm produces: https://fetch.spec.whatwg.org/#queue-a-fetch-task

- css transition/animation and style recalc ?
  - about computedStyle ?
- Q. how `HTMLElement#offsetWidth` interfere browser event loop ?
  - thing is offsetWidth is defined in https://www.w3.org/TR/cssom-view-1/ (today: https://www.w3.org/TR/2016/WD-cssom-view-1-20160317/)
  - so, if something "invalidates layout", script referring offsetWidth invokes re-layout, which is not necessary so often for normal "event loop" since "update the rendering" has to happen as often as reasonable animation frame.