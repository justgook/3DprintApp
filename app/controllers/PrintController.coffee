module.exports = ($scope, CoreService)->
  $scope.model = []
  $scope.print = ->
    CoreService.emit "in-print", message: ['print', 'test.gcode']
    return
  return