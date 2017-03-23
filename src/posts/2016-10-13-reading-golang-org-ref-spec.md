<!--
{
  "title": "reading golang.org/ref/spec",
  "date": "2016-10-13T15:39:40.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

Version of May 31, 2016

- dynamic type
- interface value instantiation (interface-typed value)
- runtime form (memory layout) of unanimous field
- nil-able type
- pointer-able type
- string implementation (slice)
- interface method, non interface method
- tuple return implementation (tuple type?)
- scopes
- top to bottom picture (package, import, declaration, statement, expression, opera{nd,ter})
- untyped constant or whatever
- comparison beteeen interface typed value and non interface typed value
- interface value, interface type, dynamic type
- it should talk about runtime error in the form of data structure (memory layout) used in runtime
- it should talk about compile error in the form of compiler intermidiate form
- don't talk about much of semantics
- addresability is determined statically?
- play with green thread and /proc/maps
- stack or heap

# implementation

- goto
- channel, lock/unlock
- go routine (green thread)
- type check
- memory layout
- GC
- ffi
