<!--
{
  "title": "Java from Specification",
  "date": "2017-03-17T22:43:32+09:00",
  "category": "",
  "tags": ["spec"],
  "draft": false
}
-->

# Language spec

(reference: https://docs.oracle.com/javase/specs/jls/se8/html/index.html)

- 4. Types, Values, and Variables
  - primitive type: integer, floating, bool
  - reference type: array, class, interface, null
- 12. Execution
  - class and  .class file lifecycle
- 15. Expression
  - 15.5. Expressions and Run-Time Checks
      - runtime value check
  - 15.9. Class Instance Creation Expressions
      - `new <interface>(){ <some func def> }` is an anonymous class declaration and its instntiation.
      - I guess, for compiler, it's only a syntactic sugar level thing.
- 17. Threads and Locks
    - java.util.concurent.Thread
    - synchronized statement
    - object monitor

# VM spec

(reference: https://docs.oracle.com/javase/specs/jvms/se8/html/index.html)

- 2. The Structure of the Java Virtual Machine
    - returnAddress type ?
    - method area (per-class global data)
    - Run-Time Constant Pool (kind of symbol table)
    - Native Method Stacks (explicitly separated from "Java Virtual Machine Stacks")
    - Operand Stacks
        - allocated within each stack frame
        - kind of traditional stack in the sense of stack machine
    - 2.6.3. Dynamic Linking
        - each method's depending reference information is kept in method area's constant pool,
          so vm can load and resolve those references on the fly.
        - 5.4.3 for detail
    - 2.9. Special Methods
        - clinit:
            - accomodate static initializer (static block)
            - does vm-implemented class loder call it ? (does compiler emit this instruction?)
        - init:
            - does compiler emit along with new ?
    - 2.11.10. Synchronization
        - synchronized method must be handled implicitly. (no special vm level instruction)
- 5. Loading, Linking, and Initializing
    - 5.4.3. Resolution

# Standard library spec

(reference: http://docs.oracle.com/javase/8/docs/api/)

- "hacky" libraries
    - java.lang (Class, ClassLoader)
    - java.lang.reflect
    - java.util.concurrent

# Future work

- Read some mplementaion
    - openjdk
    - android runtime

- Follow some implementation topics
    - gc
    - theading
    - c call (ffi)
    - type checking/inference
