require 'angular'
require 'angular-animate'
module.exports = angular.module 'application', ['ngAnimate']


.service 'CoreService', require './services/CoreService.coffee'
.service 'FilesService', require './services/FilesService.coffee'

.controller 'ConnectionController', require './controllers/ConnectionController.coffee'
.controller 'FilesController', require './controllers/FilesController.coffee'
.controller 'TerminalController', require './controllers/TerminalController.coffee'
.controller 'PrintController', require './controllers/PrintController.coffee'
# .directive 'tab', require './directives/TabDirective.coffee'


# console.log require 'dropzone'