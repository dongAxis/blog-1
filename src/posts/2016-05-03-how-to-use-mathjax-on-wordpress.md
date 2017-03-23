<!--
{
  "title": "How to Use MathJax on Wordpress",
  "date": "2016-05-03T05:17:56.000Z",
  "category": "",
  "tags": [
    "wordpress",
    "tex"
  ],
  "draft": false
}
-->

Instead of installing [any kinds of plugin](https://wordpress.org/plugins/tags/tex), I added mathjax script on _header.php_ directly.
Here is a relevant change: [hi-ogawa/wordpress-revisr (commit: 999b7d)](https://github.com/hi-ogawa/wordpress-revisr/commit/999b7d10fca84ea56d0789130109e87170016fd4)

### Demo

__Before:__

```
Block Codes:

\\[1 + 1 = 100\\]

$$ F_{S, A}(X) = X^S + A $$

Inline Codes:

- bla ... \\(x_0 + x_1 = y^{-9}\\) bla...

- bla ... $x_0 + x_1 = y^{-9}$ bla...
```

__After:__

--- 

Block Codes:

\\[1 + 1 = 100\\]

$$ F_{S, A}(X) = X^S + A $$

Inline Codes:

- bla ... \\(x_0 + x_1 = y^{-9}\\) bla...

- bla ... $x_0 + x_1 = y^{-9}$ bla...

---

Since Wordpress Editor doesn't recognize backslash `\` itself, you need to escape with another backslash. That's why you see `\\` in above example.

### References

- [docs.mathjax.org](http://docs.mathjax.org/en/latest/start.html#tex-and-latex-input)
- [display-math-symbol-in-ghost](http://wp.hiogawa.net/2015/11/19/display-math-symbol-in-ghost/)