<!--
{
  "title": "Wordpress Code Highlighting",
  "date": "2016-04-25T02:59:34.000Z",
  "category": "",
  "tags": [
    "wordpress"
  ],
  "draft": false
}
-->

### Cheapest approach

- open `header.php` from wordpress editor and add [google/code-prettify](https://github.com/google/code-prettify) script like below:

```prettyprint
...
&lt;?php wp_head(); ?&gt;
&lt;script src=&quot;https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js&quot;&gt;&lt;/script&gt;
&lt;/head&gt;
...
```

- add `prettyprint` after three backticks for code blocks:

```prettyprint
 ```prettyprint
 ```
```

[here](https://github.com/hi-ogawa/wordpress-revisr/commit/617017dc8d4a876bc399e7748d5047f48707bf55) is a change.

### Small thing

The theme I use didn&#039;t do well about code styling, so I changed it from editor:

```prettyprint
pre {
overflow-x: scroll;
}
```

[here](https://github.com/hi-ogawa/wordpress-revisr/commit/4b1599e04393e3af146a8e202f4a789e2a704d26) is a change.

### Reference

- good one: [css-tricks: posting-code-blocks-wordpress-site](https://css-tricks.com/posting-code-blocks-wordpress-site/)
- [hongkiat: wordpress-manage-code-snippets](http://www.hongkiat.com/blog/wordpress-manage-code-snippets/)
- [wordpress.com: posting-source-code](https://en.support.wordpress.com/code/posting-source-code/)