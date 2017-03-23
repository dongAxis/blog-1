<!--
{
  "title": "Various Patterns of Iteratee",
  "date": "2016-05-03T21:09:11.000Z",
  "category": "",
  "tags": [
    "iteratee",
    "haskell",
    "category-theory"
  ],
  "draft": false
}
-->

On the way of creating my first Haskell web app with [snap](http://snapframework.com/), I came across with [Iteratee](http://hackage.haskell.org/package/snap-core-0.9.8.0/docs/Snap-Iteratee.html#g:3).
Since I have a background of studying _Category Theory_ (especially _Coalgebra Theory_), it was easy to understand the definition of _Iteratee_ in its simplest form explained in [Haskell Wiki](https://wiki.haskell.org/Enumerator_and_iteratee). But, at certain point, [the real/practical definition of Iteratee](http://hackage.haskell.org/package/snap-core-0.9.8.0/docs/Snap-Iteratee.html#g:3) overwhelmed me.

So, this post (and my implementations [IterateeNonWaitable](https://github.com/hi-ogawa/haskell_playground/blob/ce4071508e06362358f4ed173d6dab10d1281799/src/IterateeNonWaitable.hs), [IterateeWaitable](https://github.com/hi-ogawa/haskell_playground/blob/ce4071508e06362358f4ed173d6dab10d1281799/src/IterateeWaitable.hs)) is:

- to fill the gap between the simplest form and practical form, and,
- to re-explain some notions of _Iteratee_ with _Category Theory_.

# Simplest Definition

Starting from the definition of "Simplest" Iteratee I've used in [IterateeNonWaitable](https://github.com/hi-ogawa/haskell_playground/blob/ce4071508e06362358f4ed173d6dab10d1281799/src/IterateeNonWaitable.hs):

```prettyprint
data Iteratee s a
  = Continue (s -&gt; Iteratee s a)
  | Yield a
```

This algebraic data type satisfies the equation below (here `Iteratee s` = $T_{s}$):

$$
T_{S}(A) = T_{S}(A)^S + A.
$$

So, this Monad can be written with $\\mu$ notation:

$$
T_{S}(A) = \\mu X. (X^S + A)
$$

If you look at the page 3 in the paper [Notions of computation and monads, Eugenio Moggi](http://core.ac.uk/download/pdf/21173011.pdf), you'll see this definition is exactly same to what's introduced as "interactive input monad", $T(A) = (\\mu\\gamma.A + \gamma^U)$.

Considering $X^S = \\prod_{s \\in S}X$, each element can be considered to be some kind of tree as below:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.17.36-e1462340509108-1024x297.jpg"><img class="alignnone wp-image-385 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.17.36-e1462340509108-1024x297.jpg" alt="2016-05-04 14.17.36" width="580" height="168" /></a>

# "Waitable" Definition 

I found the previous definition is too weak to accommodate "waiting-for-coming-input" state. So, I changed a definition from [IterateeNonWaitable](https://github.com/hi-ogawa/haskell_playground/blob/ce4071508e06362358f4ed173d6dab10d1281799/src/IterateeNonWaitable.hs) to [IterateeWaitable](https://github.com/hi-ogawa/haskell_playground/blob/ce4071508e06362358f4ed173d6dab10d1281799/src/IterateeWaitable.hs)

```
data Iteratee s a
  = Continue (Maybe s -&gt; Iteratee s a)
  | Yield s
```

This `Iteratee` explicitly assumes input set includes "waiting instruction" which I represent by `Nothing`. (In the real defintion, [empty chunk](http://hackage.haskell.org/package/snap-core-0.9.8.0/docs/Snap-Iteratee.html#g:3) is used for the same purpose.)

Here is a tree representation for this pattern of definition:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.17.36-1-e1462341493742-1024x362.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.17.36-1-e1462341493742-1024x362.jpg" alt="2016-05-04 14.17.36" width="580" height="205" class="alignnone size-large wp-image-406" /></a>

# Summery

About My Implementation:

- no monad transformation (so it cannot accommodate IO processing)
- no `Exception` constructor
- no `Chunk` or `EOF`
- not leave stream (`Yield` only leaves result `a`)
- "Waitable" has `Nothing` as waiting state
- enumerator composition doesn't work for "NonWaitable" iteratee defintion
- it's impossible to implement `listFunction2Iteratee` for "NonWaitable" since `Nothing` input did good ad-hocly


Original implementation

- practical implementation of "interatcive input output monad"
  - `Chunk`-ed input
  - explicit `EOF` as input
  - explicit `Exception` state

About Enumerator:

- `Enumerator` is not a theoretically solid notion as `Iteratee`. This is only for ad-hoc programatic notion.

# Future Work

- Define `Iteratee` via [free monad](https://ncatlab.org/nlab/show/free+monad):
   - It could be something like this: [IterateeFree](https://github.com/hi-ogawa/haskell_playground/commit/f12030f80fb1f5bdbfe2f4c51c330aae8b0a4331).


- Derive `Monad` definition via [GHC "deriving" mechanism](https://downloads.haskell.org/~ghc/7.8.4/docs/html/users_guide/deriving.html)

- Theoretical foudnation for `Enumeratee`:
   - it might be a practical ad-hoc notion similer to `Enumerator`, but it might be theoretically interesting.

- Give deeper explanation using _Final Coalgebra_
   - I've ignored the fact that Haskell's algebraic data type accommodates infinite structure. So, technically/theoretically, the definition of `Iteratee` should be considered as _Final Coalgebra_:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.38.04-1024x768.jpg"><img class="alignnone size-large wp-image-391" src="http://wp.hiogawa.net/wp-content/uploads/2016/05/2016-05-04-14.38.04-1024x768.jpg" alt="2016-05-04 14.38.04" width="580" height="435" /></a>

- Try using [Iteratee in Play framework](https://www.playframework.com/documentation/2.3.x/Iteratees)

# References

- [Haskell wiki: Iteratee](https://wiki.haskell.org/Enumerator_and_iteratee)
- [Notions of computation and monads, Eugenio Moggi](http://core.ac.uk/download/pdf/21173011.pdf)
- [Playframework documentation](https://www.playframework.com/documentation/2.3.x/Iteratees)