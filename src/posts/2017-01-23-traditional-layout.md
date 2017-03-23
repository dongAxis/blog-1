<!--
{
  "title": "Traditional Layout",
  "date": "2017-01-23T16:31:18.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- example for understanding 
  - display: inline, block, line-block
  - float: left, right
  - calculation of size (especially width of block box and line box, interacting with float)

- box categorization 1st approach
  - block-level box (if display: block) (this participates in block formatting context)
    - block-level block container (any block-level box is block-level block container)
      - establish block formatting context (if it includes only block-level boxes)
      - establish inline formatting context (otherwise)
  - inline-level box (this participates in inline formatting context)
    - inline-level block container (if display: inline-block)
      - establish block formatting context (if it includes only block-level boxes)
      - establish inline formatting context (otherwise)
    - others (if display: inline)
- box categorization 2nd approach
  - block container (box which establishes a formatting context)
    - block-level block container (every display: block)
    - inline-level block container (every display: inline-block)
  - non block container (every display: inline)
- some special boxes
  - "floating" box (by float: right or left. display has no effect and it's considered to be block)
  - absolutely positioned element's box (...)
- every box should be categorized by:
  - 1. relationship with children
    - establish block formatting context or,
    - establish inline formatting context or,
    - not establish any formatting context.
  - 2. relationship with parent
    - participating in inline formatting context or,
    - participating in block formatting context or,
    - taken out from normal flow.

- how float affects other box's size and position
  - concept: "current line" of normal flow (in a vertical sense)
    - floating box doesn't change current line, but is affected by it.
    - and, essentially, only `clear` property will proceed the "current line" to the bottom the floating box.
  - in a horizontal sense
    - box (line box or block box)'s width will change according to floating boxes appearing before or after.
    - but, the size of block container of the context will include floating box.

- can floating box do relative-positioning ?
  - no, relative-positioning is the concept within normal flow, which is different type of positioning scheme.
  - [this](https://www.w3.org/TR/CSS2/images/longdesc/float2p-desc.html) looks like doing it, but it's not.

- CSS2.1, 10.3 Calculating widths and margins

  > The values of an element's 'width', 'margin-left', 'margin-right', 'left' and 'right' properties as used for layout depend on the type of box generated and on each other.

  - ? in terms of parent-to-child and child-to-parent
    - since we have percentage, do we have to calculate children first ?
    - width of containing block
      - block-level containing block
      - inline-level containing block (a.k.a. display: inline-block)