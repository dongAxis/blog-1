<!--
{
  "title": "Floating Point Number Example",
  "date": "2016-06-27T06:15:13.000Z",
  "category": "",
  "tags": [
    "haskell",
    "float"
  ],
  "draft": false
}
-->

While I was solving [this problem involving geometric calculation](http://wp.hiogawa.net/2016/06/27/uva-10084-hotter-colder-2/), I had a bad feeling about what I'm doing about floating point numbers. 
Sadly, I almost forgot what _floating point number_ is, so, I prepared [a couple of codes](https://github.com/hi-ogawa/haskell_playground/blob/7e1f703d8411066918e9205aa4f5494cf6966383/src/FloatingPointNumber.hs) jogging my memory about this fact:

```prettyprint
module FloatingPointNumber (spec) where

import Test.Hspec

f :: Float
f = undefined

spec :: Spec
spec = do
  describe "type Float" $ do
    describe "floatRadix" $ it "is 2" $
      floatRadix f `shouldBe` 2
    describe "floatDigits (the number of digits for significand)" $ it "is 24" $
      floatDigits f `shouldBe` 24
    describe "Examples" $ do
      let l = 1 :: Float
      it "1 /= 1 + 1 / 2 ^ 23" $ l /= 1 + 1 / 2 ^ 23
      it "1 == 1 + 1 / 2 ^ 24" $ l == 1 + 1 / 2 ^ 24
      it "1 /= 1.0000001"      $ l /= 1.0000001
      it "1 == 1.00000001"     $ l == 1.00000001
      it "(1 / 2 ^ 23) ^ 7 /= (1 / 2 ^ 23) ^ 6" $ (1 / 2 ^ 23) ^ 7 /= ((1 / 2 ^ 23) ^ 6 :: Float)
      it "(1 / 2 ^ 23) ^ 7 == (1 / 2 ^ 23) ^ 8" $ (1 / 2 ^ 23) ^ 7 == ((1 / 2 ^ 23) ^ 8 :: Float)
      it "2 ^ (2 ^ 7) ~ 1e39 isInfinite" $
        isInfinite (2 ^ (2 ^ 7) :: Float) &&
        isInfinite (1e39 :: Float)
      it "2 ^ (2 ^ 6) is not Infinite" $
        not $ isInfinite (2 ^ (2 ^ 6) :: Float)
```

The spec execution will print as below (the same thing can be found at the bottom of [Travis CI output](https://travis-ci.org/hi-ogawa/haskell_playground/builds/140433729)):

```
  type Float
    floatRadix
      is 2
    floatDigits (the number of digits for significand)
      is 24
    Examples
      1 /= 1 + 1 / 2 ^ 23
      1 == 1 + 1 / 2 ^ 24
      1 /= 1.0000001
      1 == 1.00000001
      (1 / 2 ^ 23) ^ 7 /= (1 / 2 ^ 23) ^ 6
      (1 / 2 ^ 23) ^ 7 == (1 / 2 ^ 23) ^ 8
      2 ^ (2 ^ 7) ~ 1e39 isInfinite
      2 ^ (2 ^ 6) is not Infinite
```

These references were helpful:

- https://codewords.recurse.com/issues/one/when-is-equality-transitive-and-other-floating-point-curiosities
- http://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html