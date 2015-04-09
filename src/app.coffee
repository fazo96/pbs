pertApp = angular.module 'pertApp', ['ui.router']

pertApp.config ($stateProvider,$urlRouterProvider,$locationProvider) ->
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode enabled: yes, requireBase: no
  $stateProvider.state 'home',
    url: '/'
    templateUrl: 'welcome.html'
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

# "Main" Controller
pertController = ($scope) ->
  $scope.toLocalStorage = (data,options) ->
    options ?= {}
    data ?= []
    if !data.push?
      return swal 'Error', 'data is not a list', 'error'
    try
      sdata = JSON.stringify data
      console.log "Saving: "+sdata
      localStorage.setItem 'ganttpert', sdata
      unless options.silent
        swal 'Ok', 'Data updated', 'success'
      $scope.pbs = new PBS(data).calculate {}, ->
        $scope.$broadcast 'dataChanged'
    catch e
      swal 'Error', e, 'error'

  $scope.fromLocalStorage = (options,cb) ->
    options = options || {}
    if options.call? then cb = options
    else unless cb?.call? then return console.log "fromLocalStorage called without callback"
    data = localStorage.getItem options.name || 'ganttpert'
    if data is null then data = "[]"
    try
      jdata = JSON.parse data
      if jdata is null then jdata = []
    catch e
      unless options.silent
        swal 'JSON Error', e, 'error'
      if options.raw
        #console.log 'Loading: []'
        cb []
      else
        #console.log 'Loading: {list: [], days: []}'
        cb list: [], days: []
    if options.raw
      #console.log 'Loading: '+jdata
      cb jdata
    else
      #console.log 'Loading: '+$scope.pbs
      new PBS(jdata).calculate (x) ->
        $scope.pbs = x
        cb x
