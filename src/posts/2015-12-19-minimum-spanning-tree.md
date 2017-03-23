<!--
{
  "title": "Minimum Spanning Tree in Haskell",
  "date": "2015-12-19T20:21:09.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell"
  ],
  "draft": false
}
-->

I'm reading [The Algorithm Design Manual](http://www.algorist.com/). Spontaneously, I implement examples in the book by myself with the language, which is also spontaneously chosen.

I wrote Prim's algorithm to solve [Minumum Spanning Tree](https://en.wikipedia.org/wiki/Minimum_spanning_tree) by Haskell. The code is [here](https://github.com/hi-ogawa/haskell_playground/blob/a75de10dab775de2fef400b0aeb872d8c54fbc5a/src/MST.hs).

#### What I learned

- `Data.Array.Diff`: to update a pure array with O(1) time,
- `Data.Lens`:
  - `%=`, `.=`, `use`: easy access to states wrapped by Monad
- `Data.Arrow`:
  - `>>>`: intuitive chaining functions
- `Data.Function`
  - `&`: to call functions as if it's object's method.

Combining `&` and `>>>` improved readability so much compared to writing only with `.`. This is an example:

<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/haskell_playground/blob/a75de10dab775de2fef400b0aeb872d8c54fbc5a/src/MST.hs?slice=88:103"></script>

#### Future Work

- Use existing graph library in haskell
- Use Kleisli arrows composition
- Use mutable collection data for better performance with `monadST`