<!--
{
  "title": "Concurrency",
  "date": "2016-08-16T17:29:16.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

### Comparisons

_Thread vs Process: (ok)_

- https://en.wikipedia.org/wiki/Thread_(computing)#Threads_vs._processes
- http://stackoverflow.com/questions/200469/what-is-the-difference-between-a-process-and-a-thread


_Multicore vs Multithreading: (ok)_

- http://stackoverflow.com/questions/11835046/multithreading-and-multicore-differences


_Non-Blocking IO vs Multi-threaded Blocking IO: (ok)_

- http://stackoverflow.com/questions/8546273/is-non-blocking-i-o-really-faster-than-multi-threaded-blocking-i-o-how
  - "One OS thread with many connection" gives an advantage to _Non-Blocking IO_
  - it's also about _context switch_
  - the limitation of the number of _threads_:
     - http://stackoverflow.com/questions/344203/maximum-number-of-threads-per-process-in-linux


_Asynchronous vs Non-Blocking vs Event-base: (ok)_

- http://stackoverflow.com/questions/2625493/asynchronous-vs-non-blocking


_Preemptive thread vs Non-Preemptive (a.k.a. Cooperative) thread: (??)_

- http://stackoverflow.com/questions/4147221/preemptive-threads-vs-non-preemptive-threads


_Haskell vs Node.js: (??)_

- http://stackoverflow.com/questions/3847108/what-is-the-haskell-response-to-node-js


_Fibers vs Threads: (??)_

- https://bjouhier.wordpress.com/2012/03/11/fibers-and-threads-in-node-js-what-for/

type of concurrency, parallel

- https://en.m.wikipedia.org/wiki/Flynn%27s_taxonomy

### Basic Reference

- Context switch:
  - https://en.wikipedia.org/wiki/Context_switch
- Green Thread:
  - https://en.wikipedia.org/wiki/Green_threads
- Thread:
  - https://computing.llnl.gov/tutorials/pthreads/#Thread
- libevent:
  - http://libevent.org/
- Flyn's anatomy:
  - https://en.wikipedia.org/wiki/Flynn%27s_taxonomy
- SMP (symmetric processing):
  - https://github.com/cirosantilli/x86-bare-metal-examples/blob/master/smp.md

### By Examples

- Node.js: 
  - http://blog.mixu.net/2011/02/01/understanding-the-node-js-event-loop/
  - https://www.youtube.com/watch?v=F6k8lTrAE2g

- Haskell
  - http://research.microsoft.com/en-us/um/people/simonpj/Papers/marktoberdorf/
  - https://github.com/snoyberg/posa-chapter/blob/master/warp.md
  - https://wiki.haskell.org/Research_papers/Parallelism_and_concurrency#Concurrent_Haskell
  - http://book.realworldhaskell.org/read/concurrent-and-multicore-programming.html

- Ruby:
  - MRI: http://www.csinaction.com/2014/10/10/multithreading-in-the-mri-ruby-interpreter/
  - JRuby: https://blog.engineyard.com/2011/concurrency-in-jruby

- HAProxy:
  - [single process, event-driven model without context-switch](http://www.haproxy.org/#perf)
    - does this mean single thread? (with a bunch of green thread?)


### Web things

- http://gwan.com/en_apachebench_httperf.html