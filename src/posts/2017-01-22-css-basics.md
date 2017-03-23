<!--
{
  "title": "CSS Basics",
  "date": "2017-01-22T14:30:26.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

# Standard

(NOTE: I introduced a concept, "Semantics part1" and "Semantics part2", but obvoiusly this is not an official term.)

- Latest snapshot as of writing: https://www.w3.org/TR/2015/NOTE-css-2015-20151013/
  - basic terminology: https://www.w3.org/TR/CSS2/conform.html
  - Syntax
      - https://www.w3.org/TR/css-syntax-3
      - [tokenizing](https://www.w3.org/TR/css-syntax-3/#token-diagrams) and [parsing](https://www.w3.org/TR/css-syntax-3/#parser-diagrams)
      - this doesn't define generated AST's validity completely since further specific module is expected to define such detail.
  - Semantics part1
      - "statically"-definable part of semantics, provided a document tree and css. For each element on a document tree, property's value is defined.
      - https://www.w3.org/TR/css3-selectors/
      - https://www.w3.org/TR/css3-values/
      - https://www.w3.org/TR/css3-cascade/
      - color, font, etc ...
  - Semantics part2
      - "dynamic" part of semantics in the sense that each part of document tree affects how each other will be presented on a media.
      - Box model: https://www.w3.org/TR/CSS2/box.html
      -  Visual formatting model (simply content positioning and sizing)
          - https://www.w3.org/TR/CSS21/visuren.html
          - https://www.w3.org/TR/CSS2/visudet.html
          - important concepts (well-defined terms):
              - viewport vs. canvas
              - element vs. box
              - containing block
              - block-level element, block-level box, principal block-level box, block container box, block box (seriously?)
              - inline-level element, inline-level box, atomic inline-level box, inline box
              - anonymous inline/block box
              - positioning schemes (normal flow, floats, and absolute positioning)
              - normal flow
                  - block formatting context
                  - inline formatting context
                      - line box
                  - relative positioning
              - calculation of "computed value" to "used value"
              - stacking context and level

- obviously, a good thing is "Semantics part2" doesn't affect "Semantics part1".
  - how about `calc` function as property value?
      - that is the matter of https://www.w3.org/TR/css3-cascade/#value-stages and "computed value" belongs to part1 and "used value" belongs to part2
- The list of `dfn` from standard, simply running below inside the document.

  ```
   > Array.prototype.slice.call(document.getElementsByTagName('dfn')).map((dfn) => dfn.innerText))
  ```

  - https://www.w3.org/TR/CSS21/visuren.html
      - viewport
      - containing block
      - Block-level elements
      - Block-level boxes
      - principal block-level box
      - block container box
      - block boxes
      - Inline-level elements
      - inline-level boxes
      - inline box
      - atomic inline-level boxes
      - positioning schemes:
      - out of flow
      - in-flow
      - flow of an element
      - positioned
      - line box
      - relative positioning
      - clearance.
      - absolutely positioned element
      - stacking context
      - stack level
      - bidirectionality
  - https://www.w3.org/TR/CSS2/visudet.html
      - containing block
      - initial containing block
      - static-position containing block
      - aligned subtree

---

# Implementation

- things I want to follow ?
  - architecture, data structures
  - (parsing)
  - layout (positioning and sizing)
  - rendering (compositing, hw accelaration)
  - updating
  - programming lauguage interface (binding)
  - ui event handling

- Blink: http://www.chromium.org/blink
  - Videos from BlinkOn: https://www.youtube.com/channel/UCIfQb9u7ALnOE4ZmexRecDg
      - Blink Architecture & Layering: https://www.youtube.com/watch?v=hCyVlkxB5E8
      - Paint and Compositing Deep Dive: https://www.youtube.com/watch?v=p4U9rfJkgdU
      - JavaScript Bindings: https://www.youtube.com/watch?v=L-n52UUqpwI
  - Blink perspective networking: http://caca.zoy.org/wiki/libcaca
  - layout: Source/core/layout
  - relation to other parts of Chromium (or just understand what each top level directory is)
    - content/ (render process)
    - ui/
    - cc/