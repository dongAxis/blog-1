<!--
{
  "title": "UVA 10065: Useless Tile Picker",
  "date": "2016-04-10T04:43:41.000Z",
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

Problem definition: https://uva.onlinejudge.org/external/100/p10065.pdf

Implementation in Haskell: https://github.com/hi-ogawa/haskell_playground/blob/master/src/Uva/P10065.hs 

Techniques: Convex hull (Graham’s scan), 2D Polygon Area calculation

# Rough Sketch

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-06-27-21.35.43.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-06-27-21.35.43-1024x768.jpg" alt="2016-06-27 21.35.43" width="584" height="438" class="alignnone size-large wp-image-982" /></a>

# Reference

- Polygon Area Calculation: http://mathworld.wolfram.com/PolygonArea.html
- Graham Scan: https://en.wikipedia.org/wiki/Graham_scan
- Determinant as Signed Area: https://en.wikipedia.org/wiki/Determinant#2_.C3.97_2_matrices