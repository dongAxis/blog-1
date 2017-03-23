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

&lt;html&gt;
&lt;head&gt;
&lt;style&gt;
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
&lt;/style&gt;
&lt;/head&gt;
&lt;body&gt;
  &lt;div class=&quot;B&quot;&gt;
    &lt;div class=&quot;C&quot;&gt;
    &lt;/div&gt;
  &lt;/div&gt;
&lt;/body&gt;
&lt;/html&gt;


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

- LayoutBlock::layout =&gt; LayoutBlockFlow::layoutBlock =&gt;
  - layoutChildren =&gt;
    - setLogicalHeight (initialize to top border and padding)
    -  layoutBlockChildren (or layoutInlineChildren) =&gt;
      - layoutBlockChild =&gt;
        - positionAndLayoutOnceIfNeeded =&gt;
          - LayoutBox::layout (recursively) ...
        - setLogicalHeight (add up child&#039;s height)
      - handleAfterSideOfBlock =&gt;
        - setLogicalHeight (add up some kind of margin collapse left over ?)
        - setLogicalHeight (add up bottom padding and bottom)
  - updateLogicalHeight (check its own height related property for the final setLogicalHeight)
    - computeLogicalHeight * 2 (different signiture) =&gt;
      - (essentially check up style&#039;s height, maxHeight, and minHeight)
      - computeLogicalHeightUsing =&gt; computeContentAndScrollbarLogicalHeightUsing =&gt;
        - (when it&#039;s percentage length) computePercentageLogicalHeight =&gt;
          - availableLogicalHeightForPercentageComputation =&gt;
            - (if containing block&#039;s height is percentage) computePercentageLogicalHeight (recursively) ...
  - setLogicalHeight (overwrite with the result of updateLogicalHeight)


$ Some notes

- for simplicity, I only care vertical part of the layout, so I setup breakpoints as below:
  - blink::LayoutView::layout
  - blink::LayoutBox::updateLogicalHeight
  - (and occasionally)  blink::LayoutBox::computePercentageLogicalHeight

- what&#039;s the difference between style and styleRef ?
  - https://cs.chromium.org/chromium/src/third_party/WebKit/Source/core/layout/LayoutObject.h?l=1322
  
- computed value vs used value (not quite sure this is right)
  - &quot;Length&quot; correponds to css computed value and &quot;LayoutUnit&quot; corresponds to css used value
  - for example, what LayoutBox::computeLogicalHeight does is to get &quot;used value&quot; from &quot;computed value&quot;.
  - https://drafts.csswg.org/css-cascade-3/#value-stages
  - https://www.w3.org/TR/CSS2/visudet.html#Computing_heights_and_margins

- LayoutView::layout is called ? times in the following way:
  - WebView initialization =&gt; FrameView::layout =&gt; (for blank document, like 3 LayoutBlocks)
    - performLayout =&gt; LayoutView::layout
    - adjustViewSizeAndLayout =&gt; ... =&gt; LayoutView::layout (a bit different from others, like 8px margin appearing somehow ?)
    - Document::layoutUpdated =&gt; ... =&gt; LayoutView::layout
  - mojom::LayoutTestControlStub =&gt; ... =&gt; RenderViewImpl::SetFocusAndActivateForTesting =&gt; ... =&gt; FrameView::layout =&gt;
    - LayoutView::layout * 2 (again for blank document ?)
  - HTMLStyleElement::dispatchPendingEvent =&gt; ... =&gt; Document::ImplicitClose =&gt; FrameView::layout =&gt;
    - LayoutView::layout * 2 (something real)
  - BlinkTestRunner::OnMessageReceived =&gt; OnReset =&gt; ... =&gt; Document::finishedParsing =&gt; ... =&gt; Document::ImplicitClose =&gt; FrameView::layout =&gt;
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