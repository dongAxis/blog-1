<!--
{
  "title": "Haskell Starter",
  "date": "2016-03-18T18:09:12.000Z",
  "category": "",
  "tags": [
    "haskell",
    "starter"
  ],
  "draft": false
}
-->

My playground repository is here: https://github.com/hi-ogawa/haskell_playground.

__General__

- Haskell Wiki
 - [How to write a Haskell program](https://wiki.haskell.org/How_to_write_a_Haskell_program)
 - [Structure of a Haskell project](https://wiki.haskell.org/Structure_of_a_Haskell_project)
- [How I Start Haskell](https://howistart.org/posts/haskell/1)
- [Cabal User Guide](https://www.haskell.org/cabal/users-guide/installing-packages.html)
- [An Introduction to Cabal sandboxes](http://coldwa.st/e/blog/2013-08-20-Cabal-sandbox.html)
- Real World Haskell: http://book.realworldhaskell.org/
- environment manager: http://docs.haskellstack.org/en/stable/README/


__Development Tips__

- `ghci` commands

```
## :type &lt;expr&gt; ##

Î»&gt; :t map
map :: (a -&gt; b) -&gt; [a] -&gt; [b]

## :info &lt;name&gt; ##

Î»&gt; :i map
map :: (a -&gt; b) -&gt; [a] -&gt; [b] 	-- Defined in â€˜GHC.Baseâ€™
Î»&gt; :i Ord
class Eq a =&gt; Ord a where
  compare :: a -&gt; a -&gt; Ordering
  ...

## :kind &lt;type&gt; ##

Î»&gt; :k Ord
Ord :: * -&gt; ghc-prim-0.4.0.0:GHC.Prim.Constraint
Î»&gt; :k []
[] :: * -&gt; *

## :browse &lt;mod&gt; ##

Î»&gt; :bro Data.List
isSubsequenceOf :: Eq a =&gt; [a] -&gt; [a] -&gt; Bool
(!!) :: [a] -&gt; Int -&gt; a
```

- Emacs
  - `C-M-d (ghc-browse-document)`: show offline module document
  - `C-c C-h (haskell-hoogle)`
  - `C-c C-l (haskell-process-load-or-reload)`

- Testing
  - whole setup: https://github.com/kazu-yamamoto/unit-test-example/blob/master/markdown/en/tutorial.md
  - hspec: http://hspec.github.io/
  - quickCheck: http://book.realworldhaskell.org/read/testing-and-quality-assurance.html
  - HUnit: http://hackage.haskell.org/package/HUnit-1.3.1.1/docs/Test-HUnit.html
  - Travis CI: https://docs.travis-ci.com/user/languages/haskell


- Debugging
  - https://wiki.haskell.org/Debugging
  - https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghci-debugger.html

- Emacs setup
  - https://github.com/serras/emacs-haskell-tutorial/blob/master/tutorial.md
  - http://stackoverflow.com/questions/25580561/how-can-i-use-cabal-repl-instead-of-ghci-in-ghc-mod
  - https://howistart.org/posts/haskell/1#how-i-work
  - [ghc-mod](http://www.mew.org/~kazu/proj/ghc-mod/en/emacs.html)


__Miscellaneous__

- collection data type consideration:
  - http://stackoverflow.com/questions/9611904/haskell-lists-arrays-vectors-sequences
- syntax extensions:
  - https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/guide-to-ghc-extensions/basic-syntax-extensions