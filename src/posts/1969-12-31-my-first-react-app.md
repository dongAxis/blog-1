<!--
{
  "title": "My First React app",
  "date": "1969-12-31T15:00:00.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- webpack
- es6 syntax with babel
- react for components
- redux for app management
- react-router with redux-simple-router
- ??? for web request and ORM (backbone model could be it???)
  - need to implement by myself? (like creating a class for it and extend a response with it)

**notes**

- es6 JSX syntax check: https://babeljs.io/repl/
- component definition:
 - https://facebook.github.io/react/docs/component-specs.html
 - es6 style: https://facebook.github.io/react/docs/reusable-components.html#es6-classes
- state vs. props
- commponent rendering stages: http://busypeoples.github.io/post/react-component-lifecycle/
- asynchronously initialize components
  - https://facebook.github.io/react/tips/initial-ajax.html

**questions**

- how redux's state can be integrated into react components' state.
  - like how to force react component rendering from redux's state change
      - that is what [`ReactRedux.connect`](https://egghead.io/lessons/javascript-redux-generating-containers-with-connect-from-react-redux-visibletodolist?series=getting-started-with-redux) does.

- re-rendering cost might be huge?
 - or maybe not: https://facebook.github.io/react/docs/multiple-components.html#a-note-on-performance