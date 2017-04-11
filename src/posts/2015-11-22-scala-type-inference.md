<!--
{
  "title": "Scala Type Inference",
  "date": "2015-11-22T22:21:25.000Z",
  "category": "",
  "tags": [
    "scala",
    "type"
  ],
  "draft": false
}
-->

I was writing this scala code with `scalaz._`:

<pre class="prettyprint">
def foldLeftError[A, B, E] : Traversable[A] => B => ((B, A) => /[E, B]) => /[E, B] =
  tr => b => f => tr.foldLeft(/-(b)){
    (eb : /[E, B], a : A) => eb flatMap ((_b : B) => f(_b, a))
  }
</pre>

Then I found this type error:

```
> compile
[info] Compiling 1 Scala source to /Users/hiogawa/repositories/mine/algorithm_practice/target/scala-2.11/classes...
[error] /Users/hiogawa/repositories/mine/algorithm_practice/src/main/scala/data_structures/P3_1.scala:22: type mismatch;
[error]  found   : scalaz./[E,B]
[error]  required: scalaz./-[B]
[error]       (eb : /[E, B], a : A) => eb flatMap ((_b : B) => f(_b, a))
[error]                                    ^
[error] one error found
[error] (compile:compileIncremental) Compilation failed
[error] Total time: 1 s, completed Nov 23, 2015 3:49:19 PM
```

I couldn't shortly find out which expression was wrong since the error message seems suggesting something wrong about `flatMap`, which could mean any of the caller object `eb`, the argument `((_b : B) => f(_b, a))` or the returned expression `eb flatMap ((_b : B) => f(_b, a))` is wrong.

While struggling with this error, I turned on Ensime (emacs plugin for fly type checker), then the error point turned a bit obvious:

![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/Screen_Shot_2015_11_23_at_16_09_21-1448262586251.png)

So, I just needed to explicitly give type anotation for `/-(b)` to be typed as `/[E,B]` instead of `/-[B]` like this:

<pre class="prettyprint">
def foldLeftError[A, B, E] : Traversable[A] => B => ((B, A) => /[E, B]) => /[E, B] =
  tr => b => f => tr.foldLeft(/-(b) : /[E, B]){
    (eb : /[E, B], a : A) => eb flatMap ((_b : B) => f(_b, a))
  }
</pre>


I thought Haskell's type error message is more sophiscated than scala or I think there's some compile option for enabling verbose type error. I will dig into those some time.

And of course, I need to learn what kind of inference is possible to have from scala compiler. Honestly, I wanted the compiler to notice `/-(b)` to be `/[E, B]` automatically in this kind of situation.