<!--
{
  "title": "input interrupt",
  "date": "2016-10-23T06:55:05.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- input handling as single thread, how is this possible?
- does game engine need another thread for waiting for input? (one thread needs to update frame constantly.)
  - USUALLY POLLING!? http://www.glfw.org/docs/latest/quick_guide.html#quick_process_events

---

#
 
- hierarchy
  - Device -> Kernel -> Driver  (module) -> Device file -> User process
  - for tty-based process (e.g. bash), what's matter is only current /dev/tty (char device file).
  - for user program run from shell (without taking on /dev/tty), it's interactive input (stdin) is under shell's control.

- how getty gets input at raw tty
- how terminal on x gets input (x (window manager) needs to manage which application to send)
- signal handler is polling?

# Question

- how is input handling done in Urho3D/SDL?
  - does it need another thread to wait for input from window system?
- let's start from basic ui library
  - xcb