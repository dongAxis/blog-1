<!--
{
  "title": "Garbage Collection By Languages",
  "date": "2016-08-27T22:28:06.000Z",
  "category": "",
  "tags": [
    "garbage-collection"
  ],
  "draft": false
}
-->

# By Language/Platform

- Haskell (GHC)
  - generational, copying
  - https://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Storage/GC
  - https://ghc.haskell.org/trac/ghc/wiki/Commentary/Rts/Storage/GC/Copying
  - https://wiki.haskell.org/Research_papers/Runtime_systems#Garbage_collection
- Go: 
  - 1.5 non-generational, non-moving, concurrent, tri-color, mark&sweep (with write barriers)
  - https://docs.google.com/document/d/16Y4IsnNRCN43Mx0NZc5YXZLovrHvvLhK_h0KN8woTO4/edit
  - https://blog.golang.org/go15gc
- Android (ART)
  - non-moving, generational, concurrent, mark and sweep (with occasional compaction)
  - https://source.android.com/devices/tech/dalvik/gc-debug.html
  - https://www.youtube.com/watch?v=EBlTzQsUoOw
- Javascript (v8)
  - stop-the-world, generational, (copying?) 
  - https://github.com/v8/v8/wiki/Design-Elements
- C Ruby
  - 2.1 generational, mark&sweep
  - 2.2 incremental, mark&sweep (with write barriers)
  - https://engineering.heroku.com/blogs/2015-02-04-incremental-gc/
- LLVM
  - supports a lot of collectors
  - http://llvm.org/docs/GarbageCollection.html#id22

# References

- Chapter 13 of [Modern Compiler Implementation in ML](https://www.cs.princeton.edu/~appel/modern/ml/)
- https://en.wikipedia.org/wiki/Tracing_garbage_collection
- [The Garbage Collection Handbook](http://gchandbook.org/index.html) (I didn't read this yet...)