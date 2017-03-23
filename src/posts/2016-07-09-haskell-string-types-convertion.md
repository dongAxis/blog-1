<!--
{
  "title": "Haskell String Types Convertion",
  "date": "2016-07-09T02:59:03.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": false
}
-->

Original source code is here: https://github.com/hi-ogawa/haskell_playground/pull/15

```prettyprint
{-# LANGUAGE OverloadedStrings #-}
module StringConversions where

import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString.Lazy.Char8 as BLC

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Encoding as TE

import Test.Hspec

spec :: Spec
spec = do
  let s   = &quot;hello&quot; :: String
      b   = &quot;hello&quot; :: B.ByteString
      bc  = &quot;hello&quot; :: BC.ByteString
      bl  = &quot;hello&quot; :: BL.ByteString
      blc = &quot;hello&quot; :: BLC.ByteString
      t   = &quot;hello&quot; :: T.Text
      tl  = &quot;hello&quot; :: TL.Text
  describe &quot;string-like types conversions&quot; $ do
    describe &quot;encodeUtf8, decodeUtf8&quot; $ do
      it &quot;B   -&gt; T&quot;   $ TE.decodeUtf8 b == t
      it &quot;T   -&gt; B&quot;   $ TE.encodeUtf8 t == b
    describe &quot;fromStrict, toStrict&quot; $ do
      it &quot;B   -&gt; BL&quot;  $ BL.fromStrict b == bl
      it &quot;BL  -&gt; B&quot;   $ BL.toStrict bl == b
      it &quot;BLC -&gt; BC&quot;  $ BLC.fromStrict bc == blc
      it &quot;BC  -&gt; BLC&quot; $ BLC.toStrict blc == bc
      it &quot;TL  -&gt; T&quot;   $ TL.fromStrict t == tl
      it &quot;T   -&gt; TL&quot;  $ TL.toStrict tl == t
    describe &quot;pack, unpack&quot; $ do
      it &quot;S   -&gt; T&quot;   $ T.pack s == t
      it &quot;S   -&gt; TL&quot;  $ TL.pack s == tl
      it &quot;S   -&gt; BC&quot;  $ BC.pack s == bc
      it &quot;S   -&gt; BLC&quot; $ BLC.pack s == blc
      it &quot;T   -&gt; S&quot;   $ T.unpack t == s
      it &quot;TL  -&gt; S&quot;   $ TL.unpack tl == s
      it &quot;BC  -&gt; S&quot;   $ BC.unpack bc == s
      it &quot;BLC -&gt; S&quot;   $ BLC.unpack blc == s
```