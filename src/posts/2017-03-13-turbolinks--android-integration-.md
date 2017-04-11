<!--
{
  "title": "Turbolinks (Android integration)",
  "date": "2017-03-13T17:56:52.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

```
- Turbolinks
  - window global object to hold all thigs
- Turbolinks.Controller
  - setup link click event handler to intercept
- Adapter (controller.adapter in javascript)
  - controller delegates visit action to here and this handles 
  - in android integration, it will lead to TurbolinkAdapter implementation
```

```
# Initial load driven from Android Activity

- (Java) TurbolinkSession.visit (assume the url given is the page with turbolink enabled) =>
  - webView.loadUrl

- (WebViewClient onPageFinished) =>
  - TurbolinksHelper.injectTurbolinksBridge => (run turbolinks_bridge.js) =>
    - (Js) Turbolinks.controller = new TLWebView


# Second (or later) load driven within webview with a link

- (user clicks link within WebView) =>
  - (Js) Turbolinks.controller.clickCaptured => clickBubbled => visit =>
    - TLWebView.visitProposedToLocationWithAction (as Turbolinks.controller.adapter) =>
      - (Java) TurbolinkSession.visitProposedToLocationWithAction (as js TurbolinksNative object) =>
        - TurbolinksHelper.runOnMainThread =>
          - (on Activity thread) TurbolinksAdapter.visitProposedToLocationWithAction
            - (your implementation, but usually) 

# Back action
- ?


Q. does Android webview adapter (TLWebview) overwrite BrowserAdapter ?
```