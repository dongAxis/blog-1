<!--
{
  "title": "Display math symbol in Ghost blog (even in Admin Preview)",
  "date": "2015-11-19T03:32:41.000Z",
  "category": "",
  "tags": [
    "ghost"
  ],
  "draft": false
}
-->

#### Setup

1. Load _Mathjax_ scripts in blog view and admin view templates:
   [hi-ogawa/hiogawa-blog-ghost (commit:48bc674)](
https://github.com/hi-ogawa/hiogawa-blog-ghost/commit/48bc674a237002ec692409a8cc938477b297b8b6)

2. Periodically call _Mathjax_ rendering function in admin view:
   [hi-ogawa/hiogawa-blog-ghost (commit:5e9f732)](https://github.com/hi-ogawa/hiogawa-blog-ghost/commit/5e9f7320cf8bbaf704c6489e8775459d4d1da74a)

#### Examples

- _Display_ style:

\\[1 + 1 = 100\\]

- _Inline_ style:
  bla bla ... \\(x_0 + x_1 = y^{-9}\\) ... bla bla...

And these examples are shown in admin preview like this:
![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/Screen_Shot_2015_11_19_at_21_33_47-1447936447461.png)

---
###### References
- <a href="http://blog.mollywhite.net/how-to-display-mathematical-equations-in-ghost/"><a href="http://blog.mollywhite.net/how-to-display-mathematical-equations-in-ghost/">http://blog.mollywhite.net/how-to-display-mathematical-equations-in-ghost/</a>
- <a href="https://www.mathjax.org/">https://www.mathjax.org/</a>