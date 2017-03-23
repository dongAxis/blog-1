<!--
{
  "title": "Haskell Readings",
  "date": "2016-08-08T13:38:37.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": true
}
-->

# Reference

- https://ghc.haskell.org/trac/ghc/wiki/ReadingList
- http://www.stephendiehl.com/posts/essential_compilers.html
- https://wiki.haskell.org/Research_papers

# What I read so far

- [​Tackling the awkward squad: monadic input/output, concurrency, exceptions, and foreign-language calls in Haskell](https://research.microsoft.com/en-us/um/people/simonpj/papers/marktoberdorf/mark.pdf)
- [Applicative programming with effects](http://www.staff.city.ac.uk/~ross/papers/Applicative.html)
- [Scrap your boilerplate: a practical approach to generic programming](http://research.microsoft.com/en-us/um/people/simonpj/papers/hmap/index.htm)
- [Fun with type functions](http://research.microsoft.com/en-us/um/people/simonpj/papers/assoc-types/fun-with-type-funs/typefun.pdf)
- [Beautiful Concurrency](https://www.schoolofhaskell.com/school/advanced-haskell/beautiful-concurrency)

# Reading

- [Implementing lazy functional languages on stock hardware: the Spineless Tagless G-machine](http://research.microsoft.com/~simonpj/papers/spineless-tagless-gmachine.ps.gz)
- [C--: a portable assembly language that supports garbage collection](http://research.microsoft.com/en-us/um/people/simonpj/papers/c--/ppdp.ps.gz)
  - STG to Cmm compilation is platform-dependent
- [The STG runtime system (revised)](http://www.haskell.org/ghc/docs/papers/run-time-system.ps.gz)

# Will read soon

- More about runtime 
  - [How to make a fast curry: push/enter vs eval/apply](http://research.microsoft.com/en-us/um/people/simonpj/papers/eval-apply/)
  - Parralelism, Concurrency, Threads
      - https://wiki.haskell.org/Research_papers/Parallelism_and_concurrency
  - Garbage Collection
  - FFI
- Somthing about type class (ad-hoc polymorphism) type inference/checking algorithm
  - [Type Classes in Haskell](http://research.microsoft.com/~simonpj/Papers/classhask.ps.gz)
- Something about System FC
  - [System FC, as implemented in GHC](http://git.haskell.org/ghc.git/blob/refs/heads/master:/docs/core-spec/core-spec.pdf)

- Something about pure data structure/algorithm:
  - [Purely Functional Data Structures](https://www.cs.cmu.edu/~rwh/theses/okasaki.pdf)