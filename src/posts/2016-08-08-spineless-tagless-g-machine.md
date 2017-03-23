<!--
{
  "title": "Spineless Tagless G-machine",
  "date": "2016-08-08T13:39:27.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": true
}
-->

# Summery 

- STG language syntax
  - important constraints: 
     - constructor and primitive operation have to be saturated (saturation)
     - function argument has to be given as variable (simple application)
     - `let(rec)` cannot bind a variable for unboxed type. Instead, pattern match has to be used.
- Core to STG translation
- Operational Semantics for STG language on STG machine
- STG language to C code generation and Runtime C
- let's ignore "Comparison of many possibilities" and "Optimization" discussions
  - black hole
  - "tag return" vs "vector return" for constructor 

---

# Things to do/consider

- invariant predicates about stg machine states
- simulate STG code/machine which use rules 15, 17
  - 17 and 17 a with concrete example 
- STG to C code generation 
  - maybe it's better to understand cmm instead ?
- simulate generated code 
- figure 5 
  - extend with constructor code showing `RetData1` assignment and jump
  - add annotation
    - each code to corresponding sub section e.g.  `RetData1` <- 9.4.3
  - connect corresponding parts between original STG and generated C
- binding: atom (literal or variable) ->  value (primitive int or address)
  - literal, variable -> primitive int
      - this biding happens when entering function involving primitive argument or pattern match binding
  - variable -> address
- `f (1 + 1 + 1)` as STG
  - have to use `case` instead of `let`

- examples
  - updatable closure
  - higher order function (e.g. compose, twice, map)
  - unevaluated argument (e.g. const)
  - 9.3 (compose)

- global variable in generated C code
  - general one (e.g. `SpA`, `Node`)  <- TODO: list all of this type!
  - specific to source code (e.g. function label `map_info`, `map_entry`)

- implementation of "environment" 
  - environment means scope
  - scope means stack

---

Examples

```prettyprint
-- original expression
e = f (1# +# 1# +# 1#)

-- valid STG expression
e =
  let x = 1# +# 1#
      y = x# +# 1#
  in
  f y

-- invalid STG expression
e =
  case 1# +# 1# of
    x -&gt;
      case x +# 1# of
        y -&gt; f y
```