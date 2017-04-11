<!--
{
  "title": "Blink layout code reading around height calcualtion",
  "date": "2017-02-28T05:25:54.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

__Summery__: blink layout code reading to clear my confusion around max-height, which by the way should be able to be understood only by reading spec well.

# Following some trivial part of layout algorithm

```
$ Input

<html>
<head>
<style>
* {
  margin: 0;
  padding: 0;
  border: 0;
}

html {
  height: 100%;
}

body {
  height: 300px;
}

.B {
  max-height: 200px;
  overflow: hidden;
  background: green; width: 180px;
}

.C {
  height: 250px;
  background: blue; width: 140px;
}
</style>
</head>
<body>
  <div class="B">
    <div class="C">
    </div>
  </div>
</body>
</html>


$ Output

layer at (0,0) size 800x600
  LayoutView at (0,0) size 800x600
layer at (0,0) size 800x600
  LayoutBlockFlow {HTML} at (0,0) size 800x600
    LayoutBlockFlow {BODY} at (0,0) size 800x300
layer at (0,0) size 180x200 scrollHeight 250
  LayoutBlockFlow {DIV} at (0,0) size 180x200 [bgcolor=#008000]
    LayoutBlockFlow {DIV} at (0,0) size 140x250 [bgcolor=#0000FF]


$ Code path (focusing how setLogicalHeight is called for one LayoutBlock)

- LayoutBlock::layout => LayoutBlockFlow::layoutBlock =>
  - layoutChildren =>
    - setLogicalHeight (initialize to top border and padding)
    -  layoutBlockChildren (or layoutInlineChildren) =>
      - layoutBlockChild =>
        - positionAndLayoutOnceIfNeeded =>
          - LayoutBox::layout (recursively) ...
        - setLogicalHeight (add up child's height)
      - handleAfterSideOfBlock =>
        - setLogicalHeight (add up some kind of margin collapse left over ?)
        - setLogicalHeight (add up bottom padding and bottom)
  - updateLogicalHeight (check its own height related property for the final setLogicalHeight)
    - computeLogicalHeight * 2 (different signiture) =>
      - (essentially check up style's height, maxHeight, and minHeight)
      - computeLogicalHeightUsing => computeContentAndScrollbarLogicalHeightUsing =>
        - (when it's percentage length) computePercentageLogicalHeight =>
          - availableLogicalHeightForPercentageComputation =>
            - (if containing block's height is percentage) computePercentageLogicalHeight (recursively) ...
  - setLogicalHeight (overwrite with the result of updateLogicalHeight)


$ Some notes

- for simplicity, I only care vertical part of the layout, so I setup breakpoints as below:
  - blink::LayoutView::layout
  - blink::LayoutBox::updateLogicalHeight
  - (and occasionally)  blink::LayoutBox::computePercentageLogicalHeight

- what's the difference between style and styleRef ?
  - https://cs.chromium.org/chromium/src/third_party/WebKit/Source/core/layout/LayoutObject.h?l=1322
  
- computed value vs used value (not quite sure this is right)
  - "Length" correponds to css computed value and "LayoutUnit" corresponds to css used value
  - for example, what LayoutBox::computeLogicalHeight does is to get "used value" from "computed value".
  - https://drafts.csswg.org/css-cascade-3/#value-stages
  - https://www.w3.org/TR/CSS2/visudet.html#Computing_heights_and_margins

- LayoutView::layout is called ? times in the following way:
  - WebView initialization => FrameView::layout => (for blank document, like 3 LayoutBlocks)
    - performLayout => LayoutView::layout
    - adjustViewSizeAndLayout => ... => LayoutView::layout (a bit different from others, like 8px margin appearing somehow ?)
    - Document::layoutUpdated => ... => LayoutView::layout
  - mojom::LayoutTestControlStub => ... => RenderViewImpl::SetFocusAndActivateForTesting => ... => FrameView::layout =>
    - LayoutView::layout * 2 (again for blank document ?)
  - HTMLStyleElement::dispatchPendingEvent => ... => Document::ImplicitClose => FrameView::layout =>
    - LayoutView::layout * 2 (something real)
  - BlinkTestRunner::OnMessageReceived => OnReset => ... => Document::finishedParsing => ... => Document::ImplicitClose => FrameView::layout =>
    - LayoutView::layout * 2 (again for blank document ?)
```


# the problem I was wondering

- example: http://codepen.io/hiogawa/pen/OpLKyp
- related spec (essentially CSS 2.1 chapter 10)
  - https://www.w3.org/TR/CSS2/visudet.html#min-max-heights
  - https://www.w3.org/TR/CSS2/visudet.html#the-height-property
  - https://www.w3.org/TR/CSS2/visudet.html#Computing_heights_and_margins

Here are some points explaining that behaviour:

- "max-height" is not "height" (too obvious ...), so when you didn't specify height, it will be auto.
- percent height property will be computed as 'auto' when its containing block doesn't have some "explicit" height property.
- max-height requires "used height calculation algorithm" to run again when the first result of it exceeds max-height value. But, it doesn't run children layout algorithm again, obviously.