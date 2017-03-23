<!--
{
  "title": "UVA 10051: Tower of Cubes",
  "date": "2016-04-23T20:08:55.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "haskell",
    "uva"
  ],
  "draft": false
}
-->

[Problem definition](https://uva.onlinejudge.org/external/100/10051.html)

[Implementation in Haskell](https://github.com/hi-ogawa/haskell_playground/blob/893f10865ef57374280324dcfafdaf3cb507f4a0/src/Uva/P10051.hs)

### Rough Notes

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-20.16.25.edited-1-1024x768.jpg"><img class="alignnone size-large wp-image-160" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-23-20.16.25.edited-1-1024x768.jpg" alt="2016-04-23 20.16.25.edited" width="660" height="495" /></a>

### Small Tips

The correct answers of this problem are not unique so I need to check if my answer finds highest stack kind of manually. For that purpose, I tried two GUI diff tools.

- [opendiff (from Xcode)](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/opendiff.1.html)
  - invoked by following command:

```
$ opendiff ./resources/UVA10051.alt.output ./resources/UVA10051.output
```

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-24_1403-1024x819.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-24_1403-1024x819.png" alt="2016-04-24_1403" width="660" height="528" class="alignnone size-large wp-image-163" /></a>


- [ediff (in emacs)](https://www.emacswiki.org/emacs/EdiffMode)
  - invoked via `M-x ediff`

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-24_1404-1024x858.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-24_1404-1024x858.png" alt="2016-04-24_1404" width="660" height="553" class="alignnone size-large wp-image-164" /></a>