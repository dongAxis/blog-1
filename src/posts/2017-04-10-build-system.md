<!--
{
  "title": "Cmake and Ninja",
  "date": "2017-04-10T11:56:51+09:00",
  "category": "",
  "tags": ["cmake", "ninja"],
  "draft": true
}
-->

I've wanted to understand at least one (meta) build system from implementation.
I don't feel like going through GNU Make, so I'll go with Cmake and Ninja,
which I'm a bit familiar with because of Chromium, LLVM, and KDE.

# Build Cmake with Cmake and Ninja

```
$ git clone https://gitlab.kitware.com/cmake/cmake.git
$ mkdir -p out/Debug
$ cmake -G Ninja ../..
$ cmake -LA # check configurable variables
$ ninja -j 2 cmake
$ ninja -t browse --port=8000 --no-browser cmake # check build dependency
```

# Cmake

```
- main => ?
```

## Architecture

- Input (CMakeLists.txt)
- Output

  ```
  - CmakeCahce.txt
  - CmakeFiles/<some-directory>.dir
  - build.ninja
  - rules.ninja
  - .ninja_deps .ninja_log (it's from ninja ?)
  ```

- Generator
- Module
- Variable
- DSL

# Build Ninja with Ninja

Later.

# Read Ninja

Later.

# Reference

- Cmake: https://gitlab.kitware.com/cmake/cmake
- Ninja: https://github.com/ninja-build/ninja
