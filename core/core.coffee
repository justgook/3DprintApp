fork = require('child_process').fork
EventEmitter = require('events').EventEmitter
class Core extends EventEmitter
  constructor: ->
    @server = null
    @on "in-server", @inServer
    @on "out-server", @outServer


    @serial = null
    do @startSerial
    @on "in-serial", @inSerial
    @on "out-serial", @outSerial

    @print = null
    do @startPrint
    @printerWaitForNextLineSend = false
    @on "in-print", @inPrint
    @on "out-print", @outPrint

    @storage = null


  startServer: =>
    @server = fork "#{__dirname}/server.coffee"
    @server.on 'message', (data)=> @emit "out-server", data

  stopServer: =>
    do @server.kill

  inServer: =>
    @server.send e.data

  outServer: (message)->
    @emit message.type, message.data

  startSerial: =>
    @serial = fork "#{__dirname}/serial.coffee"
    @serial.on 'message', (data)=> @emit "out-serial", data

  stopSerial: =>
    do @server.kill

  inSerial: (message)->
    @serial.send message.message
    @server.send type: 'in-serial', data: message.message #TODO find way it happens like that.. it must be just "message"


  outSerial: (message)->
    if @server?
      @server.send type: 'out-serial', data: message
    console.log message
    if @printerWaitForNextLineSend and message[0] is 'data' and message[1] is 'ok'
      @printerWaitForNextLineSend = false
      @print.send 'next'


  startPrint: ->
    @print = fork "#{__dirname}/print.coffee"
    @print.on 'message', (data)=> @emit "out-print", data

  stopPrint: =>
    do @print.kill

  inPrint: (message)=>
    @print.send message.message
    @server.send type: 'in-print', data: message.message #TODO find way it happens like that.. it must be just "message"

  outPrint: (message)=>
    console.log "====================="
    console.log "outPrint"
    console.log message
    console.log "====================="
    if message[0] is 'line'
      @emit 'in-serial', message: ['write', message[1]]
      @printerWaitForNextLineSend = true
    @server.send type: 'out-print', data: message


module.exports = Core
