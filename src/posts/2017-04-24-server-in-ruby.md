<!--
{
  "title": "Server in Ruby",
  "date": "2017-04-24T10:17:53+09:00",
  "category": "",
  "tags": ["linux", "ruby"],
  "draft": true
}
-->

# Follow simple example

Source from rack top page:

```
require 'rack'
app = Proc.new do |env|
    ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
end
Rack::Handler::WEBrick.run app
```

Code reading:

```
(Initialization)
- Rack::Handler::Webrick.run =>
  - WEBrick::HTTPServer.new =>
    - WEBrick::GenericServer.new =>
      - Thread::SizedQueue.new(@config[:MaxClients])
      - listen =>
        - Webrick::Utils::create_listeners =>
          - Socket.tcp_server_sockets (this could get 2 sockets for ipv4 and ipv6)
          - TCPServer.for_fd (create tcp io wrapper)
  - WEBrick::HTTPServer#mount "/", Rack::Handler::WEBrick, app
  - WEBrick::HTTPServer#start =>
    - thgroup = ThreadGroup.new
    - (loop)
      - IO.select for shutdown_pipe and TCPServers
      - (if any listeners are selected after blocking)
        - Thread::SizedQueue#pop (this will block when accept_client more than MaxClients times at the same time)
        - accept_client => TCPServer#accept
        - (if successful accept) start_thread =>
          - Thread.start
          - (inside that block) =>
            - WEBrick::HTTPServer#run => (SEE BELOW)
            - Thread::SizedQueue#push(nil)
            - Socket#close

- WEBrick::HTTPServer#run =>
  - (this part will loop if keep_alive?)
  - HTTPResponse.new
  - HTTPRequest.new
  - HTTPRequest::parse =>
    - read_request_line => read_line => Socket#gets with WEBrick::Utils.timeout(@config[:RequestTimeout])
    - read_header => read_line and HTTPUtils::parse_header
    - parse_uri =>
  - service =>
    - search_servlet (returns Rack::Handler::WEBrick with application root and path)
    - get_instance => Rack::Handler::WEBrick.new
    - Rack::Handler::WEBrick#service => (SEE BELOW)
  - if WEBrick::HTTPRequest#request_line (i.e. request is complete)
    WEBrick::HTTPResponse#send_response =>
    - setup_header => (check requested http version and deal with it)
    - send_header => _write_data => Socket#<<
    - send_body => send_body_string => _write_data

- Rack::Handler::Webrick#service
  - WEBrick::HTTPRequest.meta_vars
  - WEBrick::HTTPRequest#body => read_data => Socket#read with WEBrick::Utils.timeout(@config[:RequestTimeout])
  - (setup env following Rack spec)
  - app.call(env) (Proc#call) (dispatch to Rack application)
  - update HTTPResponse#body
```


# Ruby primitives for IO and concurrency

```
Socket.tcp_server_sockets
Socket#<<
Socket#read, gets
TCPServer.for_fd
IO.select

Thread.start
Thread::SizedQueue#pop, push
GIL implementation
```


# TODO

- then later
  - rack ecosystem
  - puma implementation

- read kernel counterpart
  - file, socket (listen, accept, read, write), poll, fork, thread
