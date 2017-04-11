<!--
{
  "title": "Code highlighting in Ghost",
  "date": "2015-11-19T08:02:25.000Z",
  "category": "",
  "tags": [
    "ghost-tag"
  ],
  "draft": false
}
-->

To use code highlighing in my Ghost blog, I integrated [google code prettify](https://github.com/google/code-prettify).

#### Setup

I employed a same strategy as using [Mathjax in Ghost](http://hiogawa-blog.herokuapp.com/display-math-symbol-in-ghost/).
So, I needed a way to highlight code not only first loading phase but also periodically. But soon I could find the exact function for it here:
https://github.com/google/code-prettify/blob/master/src/prettify.js#L1604
As you can see, we can use `PR` object under the `window` object to run function for prettifing code anytime we want.

Here is the change I made:
https://github.com/hi-ogawa/hiogawa-blog-ghost/commit/4529291afeafdbfb6c3cb6096e2abefecfef884c

#### Examples

This is the example from scala. The important thing to note is you can not write `<` or `&` in code snippet. Instead you have to use `&lt:` and `&amp;`.

<pre class="prettyprint">
object Playground {

  val x : Option[Int] = ???
  val y : Option[Int] = x

 def sugar =
    for {
      x_ <- x
      y_ <- y
    } yield {x_ + y_}

  def desugar =
    x flatMap (_x => y map (_y => _x + _y))

}
</pre>

Here is how I'm writing this example in admin:
![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/Screen_Shot_2015_11_20_at_02_01_36-1447952508016.png)

#### Embeds code snippets from Github
I noticed another way to include code in blog by using [gist-it](http://gist-it.appspot.com/).
This is the example from the commit I showed at the above Setup section:

```
<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/hiogawa-blog-ghost/blob/4529291afeafdbfb6c3cb6096e2abefecfef884c/core/server/views/default.hbs?slice=58:64"></script>
```
turns into
<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/hiogawa-blog-ghost/blob/4529291afeafdbfb6c3cb6096e2abefecfef884c/core/server/views/default.hbs?slice=58:64"></script>

---
##### Reference
- https://github.com/google/code-prettify
- http://stackoverflow.com/questions/25803817/stop-html-from-being-rendered-inside-code-blocks#answer-25803869
- http://gist-it.appspot.com/