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

- (Java) TurbolinkSession.visit (assume the url given is the page with turbolink enabled) =&gt;
  - webView.loadUrl

- (WebViewClient onPageFinished) =&gt;
  - TurbolinksHelper.injectTurbolinksBridge =&gt; (run turbolinks_bridge.js) =&gt;
    - (Js) Turbolinks.controller = new TLWebView


# Second (or later) load driven within webview with a link

- (user clicks link within WebView) =&gt;
  - (Js) Turbolinks.controller.clickCaptured =&gt; clickBubbled =&gt; visit =&gt;
    - TLWebView.visitProposedToLocationWithAction (as Turbolinks.controller.adapter) =&gt;
      - (Java) TurbolinkSession.visitProposedToLocationWithAction (as js TurbolinksNative object) =&gt;
        - TurbolinksHelper.runOnMainThread =&gt;
          - (on Activity thread) TurbolinksAdapter.visitProposedToLocationWithAction
            - (your implementation, but usually) 

# Back action
- ?


Q. does Android webview adapter (TLWebview) overwrite BrowserAdapter ?
```