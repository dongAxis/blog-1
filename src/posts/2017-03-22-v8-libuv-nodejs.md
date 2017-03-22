<!--
{
  "title": "V8, libuv, and NodeJS",
  "date": "2017-03-22T14:15:27+09:00",
  "category": "",
  "tags": ["source", "linux", "javascript"],
  "draft": true
}
-->


# TODO

- Follow each layer of TCP client/server implementation
  - nodejs lib: https://nodejs.org/dist/latest-v7.x/docs/api/net.html
  - nodejs lib impl: https://github.com/nodejs/node/blob/master/lib/net.js
  - nodejs impl: (js binding and libuv call?)
  - libuv layer: http://nikhilm.github.io/uvbook/networking.html
  - libuv impl layer: (Linux socket polling)
 
- Follow blink v8 binding example

- Q. Does V8 itself keep event loop for pure javascript things (e.g. Promise) ?
  - if so, how can it integrate with libuv loop ?

- Q. How many V8 instance does blink need ?

- Compare v8 with JSC (JavascriptCore) in terms of interface


# Reference

- V8
  - https://chromium.googlesource.com/v8/v8.git
  - https://github.com/v8/v8/wiki/Embedder's-Guide
- libuv
  - https://github.com/libuv/libuv
  - http://nikhilm.github.io/uvbook/
- Nodejs
  - https://github.com/nodejs/node
  - https://nodejs.org/dist/latest-v7.x/docs/api/addons.html
