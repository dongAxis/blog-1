<!--
{
  "title": "Applicative Functor (a.k.a. Strong Lax Monoidal Functor)",
  "date": "2016-05-05T04:13:43.000Z",
  "category": "",
  "tags": [
    "haskell",
    "category-theory"
  ],
  "draft": true
}
-->

### Summery

- Motivation

- Use case:

- Theoretical exposition:


The most important line:

> pure function applied to funny arguments 


- Compositionality of _Applicative Functor_ comes from Compositionality of _strong lax monoidal functor_.

- I don't know how to deal with usual _functor_ for additional type constructor in language.

### Notes

- Original motivation for giving semantics to effectful computation by _Monad_ is:
  - equational reasoning
- But, by removing monadic equation constraint, what _Applicative_ does is to give semantics to effectful computation which could bring:
  - faster effect resolution (e.g. reader, parallel computation, _Traversable_),
  - "practically interesting" effect resolution (e.g. matrix transposition).
- I don't feel "more than one free variable" is not the point of strength required for applicative...

- In Haskell (or in $Sets$), any _Functor_ is _strong_. So, I think _strong_-ness shouldn't be emphasized in this discussion, it's confusing.

- What kind of "formal language" are we talking about for _Applicative_ computation?
  - it will be "language without _let_ (a.k.a binding)"
  - what's the crucial difference of "join" and "crushing effect (traverse effect along data structure)"?
    - traverse doesn't require "binding" ?
  - 

### References

- [Applicative Programming with Effects](http://www.staff.city.ac.uk/~ross/papers/Applicative.html)
- [hackage: Control.Applicative](http://hackage.haskell.org/package/base-4.8.2.0/docs/Control-Applicative.html)
- [nlab: Monoidal Functor](https://ncatlab.org/nlab/show/monoidal+functor)
- [Introduction to Coalgebra, Bart Jacobs](http://www.cs.ru.nl/B.Jacobs/CLG/JacobsCoalgebraIntro.pdf)
  - in part 5, it explains _strong functor_, _distributive law_ 
- [Notions of Computation and Monads, E. Moggi]()
  - in 3rd section, it explains that _strong monad_ is necessary to give semantics for the language which accommodates more than one free variable.
- [Strong categorical datatypes](http://www.sciencedirect.com/science/article/pii/0304397594000995)
- [Desugaring Haskell’s do-notation Into Applicative Operations](http://research.microsoft.com/en-us/um/people/simonpj/papers/list-comp/applicativedo.pdf)
- [Introduction to Higher-Order Categorical Logic](http://www.amazon.com/Introduction-Higher-Order-Categorical-Cambridge-Mathematics/dp/0521356539)