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
    controller: ($scope) ->
      $scope.rawdata = localStorage.getItem 'ganttpert'
      $scope.saveData = ->
        swal 'Saved', 'Your data has been updated', 'success'
        localStorage.setItem 'ganttpert', $('#ta').val()

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
  $scope.toLocalStorage = (data) ->
    try
      localStorage.setItem 'ganttpert', JSON.stringify data
      swal 'Ok', 'Data updated', 'success'
    catch e
      swal 'Error', 'could not save data', 'error'
  $scope.fromLocalStorage = (item) ->
    data = localStorage.getItem item || 'ganttpert'
    if data
      try
        jdata = JSON.parse data
      catch e
        return swal 'JSON Error', e, 'error'
      if jdata
        return new Pert(jdata).calculate()
      else return swal 'Error', 'no JSON?', 'error'
    else swal 'Error', 'no data to parse', 'error'
