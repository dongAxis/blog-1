<!--
{
  "title": "Computation and Logic",
  "date": "2016-11-04T20:34:47.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Computation

- Mathematical models of computation
  - regular expression = finite deterministic automaton
  - variants of grammer class
  - variants of automaton (push-down)
  - (primitive) recursive functions
  - Turing machine
  - Lambda calculus

- defining a model of computation means
  - defining a syntax of program
    - which means it introduces a set of programs definable within a model
  - defining a semantic of each program
    - subset of some mathematical entity

- each computation model defines a set of programs"class" of problem "domains
  - countable domain -> two value domain
    - e.g. regular expression (stream processing, generally)
  - countable domain -> countable output domain
    - e.g. integer arithmetic
  - uncountable domain -> uncountable domain
    - e.g. floating arithmetic
  - ...probabilistic variant or whatever interesting ...

# Logic

- defining a logic means:
  - defining a syntax (hopefully "encodable" to an input of program of some computation model)
    - syntax of formula
    - suntax of rules
  - defining a semantics (interpretation to domains (input is formula (which is countable) and output is validity (which is 2-value)))

# Interesting Problem

- given:
  - some computation model
  - some logic
- then find a program (definable within the given computation model) which does:
  - 

---

# related work

- where the heck "complexity" formalism come from?