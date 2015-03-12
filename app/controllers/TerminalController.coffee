module.exports = ($scope, CoreService)->
  $scope.model = []
  $scope.sendData = ''
  CoreService.on 'out-serial', (message)->
    if message?[0] is 'data'
      $scope.model.push label: "out", value: message[1]
      $scope.$apply()
    if message?[0] is 'error'
      $scope.model.push label: "error", value: message[1]
      $scope.$apply()
  CoreService.on 'in-serial', (message)->
    if message?[0] is 'write'
      $scope.model.push label: "in", value: message[1]
      $scope.$apply()
  $scope.send = ->
    CoreService.emit "in-serial", message: ["write", $scope.sendData.toString().toUpperCase() + '\r']
    $scope.sendData = ''
    return