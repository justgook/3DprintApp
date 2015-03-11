module.exports = ($scope, CoreService)->

  #read incoming messages from server
  $scope.connected = no

  CoreService.on "out-serial", (message)->
    console.log message
    switch
      when message?[0] is 'list' and message?[1]?.length
        $scope.serialPort = []
        $scope.serialPort.push (item.comName for item in message[1])...
        $scope.$apply()
      when message is 'close-connection'
        $scope.connected = no
        $scope.$apply()
      when message?[0] is 'open-connection'
        console.log 'open-connection'
        $scope.connected = yes
        $scope.serialPortSelected = message?[1]
        $scope.baudrateSelected = message?[2]
        $scope.$apply()
    return
  #send request for update list of available ports
  CoreService.emit "in-serial", message: "status"

  $scope.connect = ->
    CoreService.emit "in-serial", message: ["open", $scope.serialPortSelected, $scope.baudrateSelected]
  $scope.disconnect = ->
    CoreService.emit "in-serial", message: "close"

  $scope.baudrateSelected = 115200
  $scope.baudrate = [300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 57600, 115200]

  $scope.serialPortSelected = "SoftModem"
  $scope.serialPort = ["SoftModem"]

  $scope.collapseConection = no
