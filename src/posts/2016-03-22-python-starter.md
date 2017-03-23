<!--
{
  "title": "Python Starter",
  "date": "2016-03-22T16:25:21.000Z",
  "category": "",
  "tags": [
    "starter",
    "python"
  ],
  "draft": false
}
-->

My first pyton program is for [2d animation plot](https://github.com/hi-ogawa/haskell_playground/blob/186e09a367971019db66d2c0daaefb1ec3400441/resources/Ml/Perceptron/plot.py).

- documentation:
  - https://docs.python.org/3/
- tutorial:
  - http://docs.python-guide.org/en/latest/
- cheatsheet:
  - https://perso.limsi.fr/pointal/_media/python:cours:mementopython3-english.pdf
  - http://4code.dk/wp-content/uploads/2015/02/cheatsheet-python-grok.pdf
- self documentation:
  - http://stackoverflow.com/questions/139180/listing-all-functions-in-a-python-module
```
$ python3
&gt;&gt;&gt; help([])
Help on list object:

class list(object)
 |  list() -&gt; new empty list
 ...
&gt;&gt;&gt; i = 10
&gt;&gt;&gt; dir(i)
[..., &#039;__neg__&#039;, ...]
&gt;&gt;&gt; i.__neg__()
-10
&gt;&gt;&gt; type(i)
&lt;class &#039;int&#039;&gt;
```

- debugger:
  - [pdb](https://docs.python.org/3/library/pdb.html):  `import pdb; pdb.set_trace()`
- comparison with ruby:
   - https://www.quora.com/What-are-some-key-differences-between-Ruby-and-Python
   - http://mitsuhiko.pocoo.org/pythonruby.html
   - http://wit.io/posts/the-ugliness-of-python
-  miscs:
  - pip: http://docs.python-guide.org/en/latest/starting/install/osx/
  - matplotlib: http://matplotlib.org/users/pyplot_tutorial.html
     - animation:
         - https://jakevdp.github.io/blog/2012/08/18/matplotlib-animation-tutorial/
         - http://stackoverflow.com/questions/13216520/mac-osx-attributeerror-figurecanvasmac-object-has-no-attribute-restore-reg
  - no bundler exivalents: http://stackoverflow.com/questions/8726207/what-are-the-python-equivalents-to-rubys-bundler-perls-carton
  - map and lambda (functional programming):
     - http://www.u.arizona.edu/~erdmann/mse350/topics/list_comprehensions.html
     - http://stackoverflow.com/questions/1303347/getting-a-map-to-return-a-list-in-python-3-x
  - TODO: scipy, numpy
  - TODO: ipython: http://ipython.readthedocs.org/en/stable/


### Emacs Integration (using `python-mode`)

- Commands
  - C-c C-p: run python interpreter
  - C-c C-c: load current buffer in python interpreter
  - C-c C-l: load current file in python interpreter
  - C-c C-r: load region ...
  - C-c C-s: load string ...
  - C-c C-z: show interpreter
- NOTE:
  - `/usr/bin/python` is used for inf-process by default. so it needs to be changed when you use `python3` or `ipython`. Here is my emacs config:
```
(add-hook &#039;python-mode-hook (lambda ()
                              (setq python-shell-interpreter &quot;python3&quot;
                                    python-shell-interpreter-args &quot;-i&quot;)
                              (setq python-indent-guess-indent-offset nil)
                              (flycheck-mode)))
```
- It seems there's other option, but I didn't try:
  - https://www.emacswiki.org/emacs/PythonProgrammingInEmacs
  - https://realpython.com/blog/python/emacs-the-best-python-editor/
  - http://www.jesshamrick.com/2012/09/18/emacs-as-a-python-ide/