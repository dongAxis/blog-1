<!--
{
  "title": "Typescript Starter (CommonJS Library Development)",
  "date": "2016-07-01T20:54:25.000Z",
  "category": "",
  "tags": [
    "starter",
    "typescript"
  ],
  "draft": false
}
-->

I implemented [K-opt algorithm](http://wp.hiogawa.net/2016/06/26/k-opt-algorithm-for-tsp/) in _typescript_ and this library is published as commonJS module.

- Source code: https://github.com/hi-ogawa/typescript_kopt
- NPM package: https://www.npmjs.com/package/kopt

Not only I was curious about the usability of typescript itself, but also I wanted to know how mature the ecosystem/tooling around typescript.
As another aspect of this experiment, I wanted to try out non-browser javascript development.

# Surrounding Tools

- __typings__: type definition file (.d.ts) manager
  - https://github.com/typings/typings
- __tslint__: typescript linter 
  - https://github.com/palantir/tslint
- __mocha__: nodejs test framework 
  - https://github.com/mochajs/mocha
- __chai__: asserton library
  - https://github.com/chaijs/chai
- __watch__: monitor file change and trigger command
  - https://github.com/mikeal/watch
- __foreman__: run several commands from one console
  - https://github.com/strongloop/node-foreman
- __node-inspector__: nodejs application debugger with Chrome developer tool like interface
  - https://github.com/node-inspector/node-inspector

# Development Setup

Every executable from npm package has a wrapper command in [package.json](https://github.com/hi-ogawa/typescript_kopt/blob/7afbd4de91d026826364c949df35ee69a8e9719f/package.json) as below:

```
  &quot;scripts&quot;: {
    &quot;start&quot;: &quot;nf start&quot;,
    &quot;tsc:watch&quot;: &quot;tsc --watch&quot;,
    &quot;mocha:watch&quot;: &quot;mocha --reporter dot --watch build&quot;,
    &quot;mocha:watch_debug&quot;: &quot;mocha --debug-brk --reporter dot --watch build&quot;,
    &quot;tslint:watch&quot;: &quot;watch &#039;tslint -c tslint.json src/*&#039; src&quot;,
    &quot;inspector&quot;: &quot;node-inspector&quot;,
    ...
  },
```

Then, those npm commands are run from node version of foreman with [Procfile](https://github.com/hi-ogawa/typescript_kopt/blob/e258d282cc51144240566e84928e8c582cce288f/Procfile) as below:

```
tsc:         npm run tsc:watch
mocha:       npm run mocha:watch
mocha_debug: npm run mocha:watch_debug
inspector:   npm run inspector
tslint:      npm run tslint:watch
```

As you run `npm start`, it triggers `nf start` (`nf` is an executable from node foreman) and you're gonna see these output in console:

```
 npm start

> kopt@0.1.3 start /Users/hiogawa/repositories/mine/typescript/kopt
> nf start

[WARN] No ENV file found
[OKAY] Trimming display Output to 53 Columns
2:42:23 PM inspector.1 |  > kopt@0.1.3 inspector /Users/hiogawa/repositories/mi…
2:42:23 PM inspector.1 |  > node-inspector
2:42:23 PM tsc.1       |  > kopt@0.1.3 tsc:watch /Users/hiogawa/repositories/mi…
2:42:23 PM tsc.1       |  > tsc --watch
2:42:23 PM mocha.1     |  > kopt@0.1.3 mocha:watch /Users/hiogawa/repositories/…
2:42:23 PM mocha.1     |  > mocha --reporter dot --watch build
2:42:23 PM tslint.1    |  > kopt@0.1.3 tslint:watch /Users/hiogawa/repositories…
2:42:23 PM tslint.1    |  > watch 'tslint -c tslint.json src/*' src
2:42:23 PM mocha_debug.1 |  > kopt@0.1.3 mocha:watch_debug /Users/hiogawa/reposit…
2:42:23 PM mocha_debug.1 |  > mocha --debug-brk --reporter dot --watch build
2:42:23 PM tslint.1    |  > Watching src
2:42:23 PM mocha_debug.1 |  Error: listen EADDRINUSE :::5858
2:42:23 PM mocha_debug.1 |      at Object.exports._errnoException (util.js:855:11…
2:42:23 PM mocha_debug.1 |      at exports._exceptionWithHostPort (util.js:878:20…
2:42:23 PM mocha_debug.1 |      at Agent.Server._listen2 (net.js:1237:14)
2:42:23 PM mocha_debug.1 |      at listen (net.js:1273:10)
2:42:23 PM mocha_debug.1 |      at Agent.Server.listen (net.js:1369:5)
2:42:23 PM mocha_debug.1 |      at Object.start (_debug_agent.js:21:9)
2:42:23 PM mocha_debug.1 |      at startup (node.js:72:9)
2:42:23 PM mocha_debug.1 |      at node.js:980:3
2:42:23 PM mocha.1     |  
2:42:23 PM inspector.1 |  Node Inspector v0.12.8
2:42:23 PM inspector.1 |  Cannot start the server at 0.0.0.0:8080. Error: liste…
2:42:23 PM inspector.1 |  There is another process already listening at this ad…
2:42:23 PM inspector.1 |  Run `node-inspector --web-port={port}` to use a diffe…
[DONE] Killing all processes with signal  null
2:42:23 PM inspector.1 Exited Successfully
2:42:23 PM mocha.1     |  ․
2:42:23 PM mocha.1     |  ․
2:42:23 PM mocha.1     |    2 passing (25ms)
2:42:24 PM tsc.1       |  2:42:24 PM - Compilation complete. Watching for file …

2:42:24 PM mocha.1     |    0 passing (0ms)

2:42:24 PM mocha.1     |    ․
2:42:24 PM mocha.1     |  ․
2:42:24 PM mocha.1     |    2 passing (3ms)

...
```

Debugging interface is ready at http://127.0.0.1:8080/?port=5858. Here is an screenshot when I embed `debugger` in _kopt.spec.ts_:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-02_1339-1024x732.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-02_1339-1024x732.png" alt="2016-07-02_1339" width="584" height="417" class="alignnone size-large wp-image-1067" /></a>

# Notes

- Type definition installation:

For installation of _lodash_ type definition, as [this official tutorial](https://www.typescriptlang.org/docs/handbook/react-&-webpack.html) says, I used the command below:

```
$ typings install --global --save dt~lodash
```

But, it turned out the installed version was for version 3.10.0. Of course, what I installed from _npm_ is a latest version of lodash which is 4.13.1. So, I needed to specifiy directly the latest type definition on Github as installation source, like below:

```
$ typings install --save --global github:DefinitelyTyped/DefinitelyTyped/lodash/lodash.d.ts#68187beb94cf85c2763e258849ea63ddcbf9ad03
```

You can also specify url to raw file:

```
$ typings install --save --global lodash=https://raw.githubusercontent.com/DefinitelyTyped/DefinitelyTyped/68187beb94cf85c2763e258849ea63ddcbf9ad03/lodash/lodash.d.ts
```