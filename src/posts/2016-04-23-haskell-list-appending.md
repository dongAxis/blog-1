<!--
{
  "title": "Haskell List Appending",
  "date": "2016-04-23T19:00:21.000Z",
  "category": "",
  "tags": [
    "haskell"
  ],
  "draft": false
}
-->

Of course, right part of list is not evaluated until left part of list is finished to be shown. ([ref](http://hackage.haskell.org/package/base-4.8.2.0/docs/Data-List.html#v:-43--43-))

```
λ&gt; print $ &quot;123&quot; ++ &quot;456&quot;
&quot;123456&quot;
λ&gt; print $ &quot;123&quot; ++ undefined
&quot;123*** Exception: Prelude.undefined
λ&gt; print $ [1, 2, 3] ++ [4, 5, 6]
[1,2,3,4,5,6]
λ&gt; print $ [1, 2, 3] ++ [undefined, 4, 5, 6]
[1,2,3,*** Exception: Prelude.undefined
λ&gt; print $ [1, 2, 3] ++ undefined
[1,2,3*** Exception: Prelude.undefined
```