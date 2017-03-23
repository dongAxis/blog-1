<!--
{
  "title": "Scala Notes",
  "date": "2015-11-28T21:22:44.000Z",
  "category": "",
  "tags": [
    "scala"
  ],
  "draft": false
}
-->

### Basic References

- [Official cheatsheet](http://docs.scala-lang.org/cheatsheets/)
- [Official tutorial](http://docs.scala-lang.org/tutorials/)
- [Collection in Scala](http://docs.scala-lang.org/overviews/collections/introduction.html)
- [Scala school by twitter](http://twitter.github.io/scala_school/)
- [Effective scala by twitter](http://twitter.github.io/effectivescala/)
- [Awesome Scala](https://github.com/lauris/awesome-scala)

### Basic workflow with SBT, Ensime

- Install
[SBT (simple build tool)](https://twitter.github.io/scala_school/sbt.html) and
[Ensime (ENhanced Scala Interaction Mode for Emacs)](https://github.com/ensime/ensime-emacs)

- Generate SBT project from [my personal g8 template](https://github.com/hi-ogawa/scala_my_template.g8):
```
g8 hi-ogawa/scala_my_template.g8 --name=here-comes-directly-name-for-package
```

- Setup Ensime:
  - Run `sbt gen-ensime` in terminal or `M-x ensime-do-sbt-gen-ensime` in emacs to generates `.ensime` (a configuration file for ensime) in the package root directory.
  - Run `M-x ensime` to start ensime server in the buffer whose name is usually `*inferior-ensime-server-root*` with `comint` mode.

- Coding in Emacs
  - `C-c C-v t`: Show type
  - `C-c C-v d`: Jump to document
  - `C-c C-v i`: List available methods in inspector view
     - `,`: Navigate to previous inspector view
     - `.`: Navigate to next inspector view
  - `C-c C-v ;`: open inspector view from input ([my own extension]())
  - `M-.`: Go to source
  - `C-c C-t t`: Go to test file from implementation file
  - `C-c C-t i`: Go to implementation file from test file

- Run SBT commands
 - `C-c C-b r`: sbt run
 - `C-c C-b c`: sbt compile
 - `C-c C-b i`: sbt console ([my own extension]())
 - `C-c C-b o`: sbt testOnly &lt;test class in the current buffer>
 - `C-c C-b E`: sbt gen-ensime

- Ensime notes
  - Ensime is buggy, so if you notice any problem, just run `C-c C-c r` to have ensime to reload source files or kill `*inferior-ensime-server-root*` buffer and restart ensime server again with `ensime`.
  - In some case, `ensime` causes `waiting for connection` holding up whole emacs operation. if you see that, just long press `C-g`.
  - If you changed `build.sbt` (e.g. add new library dependency), rerun `sbt gen-ensime` and maybe `ensime`, then `C-c C-c r` to reload source files.

- SBT notes
  - Import some module automatically upon `sbt console` ([reference](http://stackoverflow.com/questions/19446406/scala-how-can-i-install-a-package-system-wide-for-working-with-in-the-repl))
```
initialCommands in console := &quot;import scalaz._, Scalaz._&quot;
```


### General tips

- check your intended library in expected repositiory e.g.
  - http://search.maven.org/
  - https://dl.bintray.com/typesafe/maven-releases/

- `???` is a Scala counterpart of Haskell's `undefined`:
http://stackoverflow.com/questions/8943967/has-scala-any-equivalence-to-haskells-undefined
- package/import
  - https://twitter.github.io/scala_school/sbt.html
  - http://www.scala-lang.org/docu/files/packageobjects/packageobjects.html

- test
  - https://twitter.github.io/scala_school/sbt.html
  - https://etorreborre.github.io/specs2/guide/SPECS2-3.6.5/org.specs2.guide.Structure.html#unit-specification
- library install
  - http://www.scala-sbt.org/0.13/tutorial/Library-Dependencies.html
  - http://www.scala-sbt.org/0.13/docs/Library-Management.html
  - https://maven.apache.org/guides/mini/guide-naming-conventions.html
- [existential type](http://www.drmaciver.com/2008/03/existential-types-in-scala/)


### Questions

- completion in console in emacs buffer
- map/dictionary in scala
- how to get to document quickly like hoogle without ensime
- is there any one command to open scala console and import current module?
- get the history of scala console within emacs


### Comparison with Haskell

- http://blog.tmorris.net/posts/what-kind-of-things-are-easy-in-haskell-and-hard-in-scala-and-vice-versa/index.html
- http://www.stackprinter.com/export?service=programmers.stackexchange&question=51245&printer=false&linktohome=true

### Play framework

- good collection of tutorials: http://www.ybrikman.com/writing/2014/03/10/the-ultimate-guide-to-getting-started/
- official document: https://www.playframework.com/documentation/2.3.x/ScalaHome
- async in play explained: https://engineering.linkedin.com/play/play-framework-async-io-without-thread-pool-and-callback-hell