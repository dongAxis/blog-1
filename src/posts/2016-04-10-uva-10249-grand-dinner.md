<!--
{
  "title": "UVA 10249: Grand Dinner",
  "date": "2016-04-10T04:29:44.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell",
    "graph",
    "max-flow"
  ],
  "draft": false
}
-->

Problem definition: https://uva.onlinejudge.org/external/102/10249.pdf

convertion to max flow problem

![](https://hiogawa-blog.s3.amazonaws.com/2016/Apr/Photo_Apr_06__13_29_23-1459917100152.jpg)

example of max flow

![](https://hiogawa-blog.s3.amazonaws.com/2016/Apr/2016_04_10_22_04_56-1460294822315.jpg)

My implementation in Haskell is here: https://github.com/hi-ogawa/haskell_playground/blob/master/src/Uva/P10249.hs

I mostly copied pseudocode written in [Wikipedia (Edmonds-Karp algorithm)](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm).

### Max flow algorithm

- http://www.ifp.illinois.edu/~angelia/ge330fall09_maxflowl20.pdf
- https://www.topcoder.com/community/data-science/data-science-tutorials/maximum-flow-augmenting-path-algorithms-comparison/
- https://en.wikipedia.org/wiki/Flow_network#Definition

### Things to prove

- Validity of Edmonds-Karp algorithm:https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm
- Validity of Fordâ€“Fulkerson method (Integer case): https://en.wikipedia.org/wiki/Ford%E2%80%93Fulkerson_algorithm
- Max flow - Min cut: https://en.wikipedia.org/wiki/Max-flow_min-cut_theorem

### Haskell things

- Mutable IO Array
- [Data.Vector.Mutable](https://hackage.haskell.org/package/vector-0.11.0.0/docs/Data-Vector-Mutable.html)
- https://wiki.haskell.org/Numeric_Haskell:_A_Vector_Tutorial