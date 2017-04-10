<!--
{
  "title": "Learn C++ From Clang",
  "date": "2017-04-08T18:59:46+09:00",
  "category": "",
  "tags": ["c++", "clang", "llvm"],
  "draft": true
}
-->

# Build from source

lldb build fails with default compiler (/usr/bin/x86_64-linux-gnu-g++-6).
So, I made separate stage to use brand-new clang to build itself.

```
$ mkdir -p out/Release
$ cd out/Release
$ cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ../..
$ ninja clang
```

```
$ mkdir -p out/Debug
$ cd out/Debug
$ CC=$PWD/../Release/bin/clang CXX=$PWD/../Release/bin/clang cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ../..
$ ninja clang clang-interpreter lldb
$ bin/lldb bin/clang-interpreter
```

# Follow examples/clang-interpreter

```
[ Example source: fib.c ]
#include <stdio.h>

int fib(int n) {
  if (n <= 1) {
    return n;
  } else {
    return fib(n - 1) + fib(n - 2);
  }
}

int main() {
  printf("fib(10) = %d\n", fib(10));
}

[ Command ]
$ bin/clang-interpreter fib.c
fib(10) = 55
```

```
[ Main path ]
- main =>

[ Data structure ]
```

# Goal

- learn some basic C++ feature
  - const, constexpr, explicit
  - dynamic things (reinterpret_cast)
  - template
  - overriding operator
  - type inference
  - lambda impl
- know runtime memory layout
  - class/namespaced functions
  - class instance
- Cmake structure
- Clang Architecture
  - preprocess ?
  - parse ?
  - optimize ?
  - emit llvm bytecode ?
- LLVM Architecture (x64 target)
