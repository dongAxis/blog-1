<!--
{
  "title": "ECMAScript (ECMA-262)",
  "date": "2017-02-13T13:56:18.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

Reading http://www.ecma-international.org/ecma-262/7.0/index.html

# Notes:

- 4.2.1: Prototype based object inheritance/sharing

> Each constructor is a function that has a property named "prototype" that is used to implement prototype-based inheritance and shared properties.
> ... Every object created by a constructor has an implicit reference

- 6.1: Language type/value
  - what you can see from programming interface

- 6.2, 7, 8, 9: Specification type/value and some helper operations on it for 10...
    - 6.2: Completion record, Reference type,  Property descripter record, Environmental records, Data block
    - 7: some helpers
    - 8 Realm, Job, Execution context, etc...
    - 9: defining internal methods and internal spots

- 10...: programming language syntax/semantics defined upon stuff from 6..9
  - how to read SS/RS
    - example: ...
  - module
    - there's no concept of source files. RS employs HostResolveImportedModule to leave module resolution to implementation.
    - so, execution of single file as an entry point is even left to implementation.