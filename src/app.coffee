pertApp = angular.module 'pertApp', ['ui.router']

pertApp.config ($stateProvider,$urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'

  $stateProvider.state 'home',
    url: '/'
    templateUrl: 'README.html'
    controller: ($scope) -> return

  $stateProvider.state 'rawedit',
    url: '/rawedit'
    templateUrl: 'rawedit.html'
    controller: pertController

  $stateProvider.state 'edit',
    url: '/edit'
    templateUrl: 'edit.html'
    controller: pertController

  $stateProvider.state 'pert',
    url: '/pert'
    templateUrl: 'pert.html'
    controller: pertController

  $stateProvider.state 'gantt',
    url: '/gantt'
    templateUrl: 'gantt.html'
    controller: pertController
  
  $stateProvider.state 'table',
    url: '/table'
    templateUrl: 'table.html'
    controller: pertController

pertController = ($scope) ->
  $scope.toLocalStorage = (data,options) ->
    options = options || {}
    try
      console.log data
      localStorage.setItem 'ganttpert', JSON.stringify data
      unless options.silent
        swal 'Ok', 'Data updated', 'success'
      $scope.$broadcast 'dataChanged'
    catch e
      swal 'Error', e, 'error'

  $scope.fromLocalStorage = (options) ->
    options = options || {}
    data = localStorage.getItem options.name || 'ganttpert'
    try
      jdata = JSON.parse data
    catch e
      unless options.silent
        swal 'JSON Error', e, 'error'
      if options.raw
        return []
      else return activities: [], days: []
    if options.raw
      return jdata
    else return new Pert(jdata).calculate()
