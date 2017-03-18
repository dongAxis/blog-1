require 'webrick'

server = WEBrick::HTTPServer.new(Port: 8000, DocumentRoot: ENV['OUT'])

trap 'INT' do
  server.shutdown
end

server.start
