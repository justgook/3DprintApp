util = require 'util'
serialport = require 'serialport'
SerialPort = serialport.SerialPort

class SerialConnection
  constructor:->
    @connection = null
    @port = null
    @baudrate = null

  open: (@port, @baudrate)=>
    @connection?.close()
    @connection = new SerialPort @port,
      baudrate: @baudrate
      parser: serialport.parsers.readline "\n"

    @connection.on "open", => process.send ['open-connection', @port, @baudrate]

    @connection.on 'data', (data)=> process.send ['data', data.toString()]

    @connection.on 'close', => process.send 'close-connection'
    @connection.on 'error', @error

  close: =>
    @connection?.close()

  status: =>
    if @connection then process.send ['open-connection', @port, @baudrate]
    else process.send 'close-connection'
    do @list
    return

  write: (m)=>
    if @connection then @connection.write m
    else @error 'not connected'
    return

  list: =>
    serialport.list (err, ports)=>
      @ports = ports
      process.send ['list', ports]
    return

  error: (e)->
    process.send ['error', e]


serialConnection = new SerialConnection

process.on 'message', (m)->
  console.log "Serial get message from core"
  console.log JSON.stringify m
  switch
    when m is 'list' then do serialConnection.list
    when m is 'close' then do serialConnection.close
    when m is 'status' then do serialConnection.status
    when util.isArray(m) and m?[0] is 'open' then serialConnection.open m[1], m[2]
    when util.isArray(m) and m?[0] is 'write' then serialConnection.write m[1]
