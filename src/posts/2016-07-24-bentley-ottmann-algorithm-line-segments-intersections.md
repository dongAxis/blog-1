<!--
{
  "title": "Bentley-Ottmann Algorithm (Line Segments Intersections)",
  "date": "2016-07-24T01:35:41.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell"
  ],
  "draft": false
}
-->

[The problem I solved before](http://wp.hiogawa.net/2016/06/27/uva-10084-hotter-colder-2/) required calculating interesections of line segments, but at that time, I only implemented naive algorithm for it.

After I read [this good survey about Bentley-Ottmann algorithm](http://www.bowdoin.edu/~ltoma/teaching/cs350/spring04/Handouts/bentley-ottmann.pdf), I'm so fascinated by this concept of _sweep line_ and its subtlety around iteration procedure (coinductive?) and data structure.
So, here I made a simple implementation Bentley-Ottmann algorithm in Haskell: [BentleyOttmann.hs](https://github.com/hi-ogawa/haskell_playground/blob/eca1254b3736ed8f7c90a1410a11ffdefacfdeb3/src/BentleyOttmann.hs).

# Algorithm Explanation

Given $n$ line segments and assuming those line segments make $k$ intersection points. This algorithm will loop for $2n + k$ times, which we call $s_1, ..., s_{2n + k}$ for each step.
Each loop represents three types of special moments (events) where sweeping horizontal line comes across:

- left end of a line segment
- right end of a line segment
- intersection of two line segments

Obviously, we know nothing about such special moments beforehand, but the algorithm leads us so that we'll know what $s_{i + 1}$ is when we're in $s_i$.
As an example, those loops are depicted as below:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-19.24.48-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-19.24.48-1024x768.jpg" alt="2016-07-24 19.24.48" width="584" height="438" class="alignnone size-large wp-image-1267" /></a>

Through each loop, we manage two types of collections, x-collection and y-collection. We also call those collections $X_i$ and $Y_i$ corresponding each loop index, respectively.
We manage $X_i$ and $Y_i$ in the way they satisfy below:

- $X_i$ keeps "possible" points (segment endpoints or interesections) which a sweep line will come across when it moves from $s_i$ to $s_{i+1}$

- $Y_i$ keeps a horizontal order of line segments which intersect with a sweep line when it moves from $s_i$ to $s_{i+1}$

The time efficiency of this algorithm comes from the fact we'll maintain $X_i$ as small as possible. In fact, we're going to keep at most $3n - 1$ elements in $X_i$ by removing intersections of non-neighboring lines at each moment, then we only keeps at most $2n$ line endpoints and at most $n - 1$ line intersections.

# Implementation

Here is type definitions and main procedure from my implementation:

```prettyprint
type Point = (Double, Double)
type Line = (Point, Point)

data XElem = LeftEnd Point Line
           | RightEnd Point Line
           | Intersect Point Line Line

type XColl = BT.BinTree XElem
type YColl = BT.BinTree Line

intersections :: [Line] -> [Point]
intersections lines =
  let
    initial = (xInitialize lines, yEmpty, []) :: (XColl, YColl, [Point])  -- <1>
    finalResult = (`fix` initial) $ \loop (xcoll, ycoll, result) ->       -- <2>
      case xDropMin xcoll of -- <2.1>
        Nothing -> result
        Just (el, xcoll') ->
          case el of
            LeftEnd (x, _) l ->                             -- (i)
              let
                (ycoll', newNeighbors, newNonNeighbors) = yInsert x l ycoll
                xcoll'' = updateXColl x newNeighbors newNonNeighbors xcoll'
              in
              loop (xcoll'', ycoll', result)

            RightEnd (x, _) l ->                            -- (ii)
              let
                (ycoll', newNeighbors, newNonNeighbors) = yDelete x l ycoll
                xcoll'' = updateXColl x newNeighbors newNonNeighbors xcoll'
              in
              loop (xcoll'', ycoll', result)

            Intersect p@(x, _) l0 l1 ->                     -- (iii)
              let
                (ycoll', newNeighbors, newNonNeighbors) = ySwap x l0 l1 ycoll
                xcoll'' = updateXColl x newNeighbors newNonNeighbors xcoll'
              in
              loop (xcoll'', ycoll', p:result)
  in
  finalResult
```

Explaining in natural language:

1. initialize 
  - _x-collection_ with given line segments' endpoints
  - empty _y-collection_
  - empty _result_
2. loop until x-collection is empty
  - x-collection isn't empty, so you can take left-most element from it
  - (i), (ii), (iii). update x-collection and y-collection depending on the type of taken element
3. return result

How to update x-collection and y-collection (step 2 (a), (b), (c)) is explained graphically in [the survey](http://www.bowdoin.edu/~ltoma/teaching/cs350/spring04/Handouts/bentley-ottmann.pdf).
So, I only shows one case at $s_4$ from the above example.

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-19.25.16-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-19.25.16-1024x768.jpg" alt="2016-07-24 19.25.16" width="584" height="438" class="alignnone size-large wp-image-1266" /></a>

Point is that the point $(b)$ is removed from x-collection at $s_4$ since $l_2$ and $l_3$ are not neighboring each other when sweep line is going from $s_4$ to $s_5$.

# Subtlety

- Comparison function for lines in y-collection changes along with sweep lines moving. So, you need to accept such function as an argument for each operation of binary search tree (e.g. `insertWith`, `swapWith` and `deleteWith`).
- I thought I can use heap (priority queue) for x-collection, but it turned out it requires arbitrary _delete_ operation in order to remove existing line intersection. So, I used binary search tree.

# Reference

- http://www.bowdoin.edu/~ltoma/teaching/cs350/spring04/Handouts/bentley-ottmann.pdf
- https://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm