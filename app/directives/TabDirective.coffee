module.exports = ($rootScope)->
  restrict: 'A'
  # templateUrl: "templates/terminal.html"
  controller: ($scope, SerialService)->

    $scope.people = [
        { label: 'Joe'},
        { label: 'Mike'},
        { label: 'Diane'}
    ]
    $scope.inputValue = ""
    $scope.messages = SerialService.data
    $scope.send = -> SerialService.send $scope.inputValue
  link: (scope, tElement, tAttrs)->
    console.log "uraaa"
    return