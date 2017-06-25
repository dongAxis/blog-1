<!--
{
  "title": "Linux Thread",
  "date": "2017-06-07T09:58:12+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

# Posix Thread

```
- pthread_create
```

# TODO

- POSIX thread implementation
- user stack separation implementation ?
  - is that in VM ?
- thread local storage implementation ?
  - arch dependent e.g. copy_thread_tls ?
  - c++ standard `thread_local`
- is libc function posix thread safe ? (e.g. malloc)

# Reference

- clone(2), pthread(7)
- musl: src/thread/
- linux: kernel/fork.c,
- Understanding the Linux Kernel 3rd edition
  - Chapter 3: Process - Creating Processes
