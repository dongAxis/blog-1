<!--
{
  "title": "Decode JSON file on Compile Time with TemplateHaskell",
  "date": "2016-07-11T09:44:51.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": true
}
-->

Original source code is here: https://github.com/hi-ogawa/haskell_playground/pull/14

In order to get started with [Yesod](http://www.yesodweb.com/) (Haskell Web Framework), It's necessary to get familiar with [Template Haskell](https://wiki.haskell.org/Template_Haskell) (GHC extension for meta-programming).

As a starer, I experimented with 
I only did know 

Is it possible to define in general way (not specific `Config` record type)?

- Debug in ghci

```
&gt; :set -XTemplateHaskell
&gt; :set -ddump-splices
&gt; :reload
```

```
&gt; :set -ddump-deriv
```

- stage issue

- typable, data class

- SYB: http://foswiki.cs.uu.nl/foswiki/GenericProgramming/SYB

# 

From template-haskell-2.11.0.0, liftData is available.

http://hackage.haskell.org/package/template-haskell-2.11.0.0/docs/Language-Haskell-TH-Syntax.html#v:liftData

```
liftData :: Data a =&gt; a -&gt; Q Exp
```

If we use this, we don't have to define `instance Lift HExp` by your own.

```
data HExp = HIntE Integer
          | HBinOpE HExp HBinOp HExp
          deriving (Show, Typeable, Data, Eq)

data HBinOp = HAddO | HSubO | HMulO | HDivO
           deriving (Show, Typeable, Data, Eq)

...

quoteHExp :: String -&gt; TH.ExpQ
quoteHExp s = do
  loc &lt;- TH.location
  let (line, col) = TH.loc_start loc
      file = TH.loc_filename loc
  THS.liftData =&lt;&lt; doParse (file, line, col) s

```

# Reference

- https://wiki.haskell.org/Quasiquotation
- https://wiki.haskell.org/Template_Haskell