<!--
{
  "title": "OPP style collection processing in Haskell",
  "date": "2016-04-11T06:00:10.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": false
}
-->

I feel this is demonstrating Haskell's type flexibility and syntax flexibility.

```prettyprint
module Chaining where

-- Motivation:
--  realize collection processing interface by chaining
--  like in ruby, scala, javascript (lodash/underscore)

import Control.Arrow ((&gt;&gt;&gt;))
import Control.Monad

-- pure case
ex0 :: IO ()
ex0 = do
  let x = ($ [0..9]) $ (
        map $ j -&gt;
          j^2
        ) &gt;&gt;&gt; (
        filter $ v -&gt;
          even v
        ) &gt;&gt;&gt; (
        flip foldl 0 $ acc v -&gt;
          acc + v
        )
  print x

-- monad case
ex1 :: IO ()
ex1 = do
  x &lt;- ($ [0..9]) $ (
    mapM $ j -&gt; do
      return (j^2)
    ) &gt;=&gt; (
    filterM $ v -&gt; do
      return (even v)
    ) &gt;=&gt; (
    flip foldM 0 $ acc v -&gt;
      return (acc + v)
    )
  print x

```