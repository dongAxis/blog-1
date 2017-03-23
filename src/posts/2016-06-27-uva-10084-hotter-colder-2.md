<!--
{
  "title": "UVA 10084: Hotter Colder",
  "date": "2016-06-27T04:42:08.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell",
    "uva",
    "geometry"
  ],
  "draft": false
}
-->

Problem Definition: https://uva.onlinejudge.org/external/100/10084.pdf

[Implementation in Haskell](https://github.com/hi-ogawa/haskell_playground/blob/a61dd4199ffb963dca2dcd293181088488882cbe/src/Uva/P10084.hs)

Techniques: 

- Lines intersection
- Polygon area calculation

# Rough Sketch

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-27-21.07.34-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-27-21.07.34-1024x768.jpg" alt="2016-06-27 21.07.34" width="584" height="438" class="alignnone size-large wp-image-992" /></a>

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-27-22.00.10-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-27-22.00.10-1024x768.jpg" alt="2016-06-27 22.00.10" width="584" height="438" class="alignnone size-large wp-image-993" /></a>

- Calculate all crossing points from half plains
- From those crossing points, select a point if it is included in all half plains
  - After this selection, points already form convex
- calculate convex area by the same approach I used here: http://wp.hiogawa.net/2016/04/10/uva-10065-useless-tile-picker/
  - it is interesting enough to note that the sign of signed area is directly used as a comparison function for couter-clockwise point sorting. [here is that part of the code](https://github.com/hi-ogawa/haskell_playground/blob/a61dd4199ffb963dca2dcd293181088488882cbe/src/Uva/P10084.hs#L74-L80)

# References

- https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
- http://www-ma2.upc.edu/vera/DAG-MAMME/IntersectingHalfplanes.pdf
  - Line/Point duality
  - line passing two points / point crossing two lines
  - Projective Plane (no-parallel-line world)
  - (I didn't do any of this)	 	 
- Bentley–Ottmann algorithm	 	 
 - https://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm
 - http://www.bowdoin.edu/~ltoma/teaching/cs350/spring04/Handouts/bentley-ottmann.pdf	 	 
 - calculate crossing points from given line segments in $O((n + k)\log(n))$ where `n` is a number of line segments and `k` is a number of crossing points. naively it's $O(n^2)$.	 	 
 - (I didn't implement this algorithm)