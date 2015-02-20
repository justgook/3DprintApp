# serialport = require("serialport");
# SerialPort = serialport.SerialPort

# # sp = new SerialPort "/dev/cu.usbmodem1421",
# #   baudrate: 115200
# #   parser: serialport.parsers.readline("\n")


# # sp.on "open", ->
# #   sp.on 'data', (data)->
# #     console.log "==========================="
# #     console.log data.toString()
# #     console.log "==========================="
# #   sp.on 'close', ->
# #     console.log('port closed.');


# process.on 'message', (m)->
#   console.log "Serial get message from core"
#   switch m
#     when 'list' then serialport.list (err, ports)-> process.send type:'list', message: ports
#     when 'open' then console.log arguments
#     # when 'list' then serialport.list (err, ports)-> process.send type:'list', message: ports

