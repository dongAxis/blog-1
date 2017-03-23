<!--
{
  "title": "UVA 10181: Fifteen Puzzle",
  "date": "2016-04-23T01:13:34.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell",
    "uva"
  ],
  "draft": false
}
-->

Problem Definition: https://uva.onlinejudge.org/external/101/10181.pdf

Implementation in Haskell: https://github.com/hi-ogawa/haskell_playground/blob/d9400f0b8ffa4f72821ac15425dd15fae35ec879/src/Uva/P10181.hs

# Rough notes about A* search algorithm

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.04.59-1024x768.jpg" rel="lightbox[x]"><img class="alignnone wp-image-122 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.04.59-1024x768.jpg" alt="2016-04-23 19.04.59" width="660" height="495" /></a>

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.06.11-1024x768.jpg" rel="lightbox[x]"><img class="alignnone wp-image-123 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.06.11-1024x768.jpg" alt="2016-04-23 19.06.11" width="660" height="495" /></a>

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.06.24-1024x768.jpg" rel="lightbox[x]"><img class="alignnone wp-image-124 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.06.24-1024x768.jpg" alt="2016-04-23 19.06.24" width="660" height="495" /></a>

&nbsp;

# 15 Puzzle Solvability

<img class="alignnone wp-image-125 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-19.06.40-1024x768.jpg" alt="2016-04-23 19.06.40" width="660" height="495" />

# Haskell things

- `Data.Heap`: https://hackage.haskell.org/package/heap-1.0.3/docs/Data-Heap.html

# References

- 15 puzzle: https://en.wikipedia.org/wiki/15_puzzle
- A* search algorithm: https://en.wikipedia.org/wiki/A*_search_algorithm