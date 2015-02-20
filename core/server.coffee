connect = require 'connect'
http = require 'http'

app = connect()
server = http.createServer(app)
io = require('socket.io')(server)

sockets = []
process.on 'message', (m)->
  console.log 'server::message'
  console.log m
  # for socket in sockets
  io.emit m.type, m.data




serveStatic = require('serve-static')

app.use serveStatic('#{__dirname}/../public', {'index': ['index.html', 'index.htm']})

io.on 'connection', (socket)->
  console.log "io.on 'connection'"
  #TODO add removing behavior
  sockets.push socket
  # process.send type: 'out-server', data: "user-connected"
  socket.on 'disconnect', ->
    console.log "socket.on 'disconnect'"

  socket.on 'in-serial', (message)->
    process.send type: 'in-serial', data: message

  socket.on 'in-storage', (message)->
    console.log "socket.on 'in-storage'"
    process.send type: 'in-storage', data: message

  socket.on 'in-print', (message)->
    console.log "socket.on 'in-print'"
    process.send type: 'in-print', data: message


server.on 'listening', ->
  console.log "server.on 'listening'"


server.listen(3000)

