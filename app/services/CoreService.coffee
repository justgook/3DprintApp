module.exports = ($rootScope)->

  io = require 'socket.io-client'
  socket = io("http://localhost:3000")
  # socket.emit "in-serial", message: "send", data: "tratatata"
  @serialData = [1,2,3,4,5,6,7,8]
  @emit = -> socket.emit.apply socket, arguments
  @on = -> socket.on.apply socket, arguments
  return
