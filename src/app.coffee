pertApp = angular.module 'pertApp', ['ui.router']

pertApp.config ($stateProvider,$urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'
  $stateProvider.state 'home',
    url: '/'
    templateUrl: 'home.html'
    controller: ($scope) ->
      $scope.rawdata = localStorage.getItem 'ganttpert'
      $scope.saveData = ->
        swal 'Saved', 'Your data has been updated', 'success'
        localStorage.setItem 'ganttpert', $('#ta').val()

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

pertApp.controller 'tableController', ($scope) ->
  $scope.list = []
  ls = $scope.fromLocalStorage()
  if ls?
    $scope.list = ls.activities

pertApp.controller 'pertDiagController', ($scope) ->
  $scope.buildGraph = (data) ->
    if !data? then return
    nodes = data.days.map (x) -> {id: x, label: ""+x}
    connections = []
    data.activities.forEach (x) ->
      connections.push
        from: x.startDay, to: x.endDay
        label: x.id+" ("+(if x.permittedDelay > 0 then x.duration+"/"+(x.duration+x.permittedDelay) else x.duration)+")"
        color: if !x.permittedDelay then 'red'
      if x.permittedDelay > 0
        connections.push
          from: x.endDay
          to: x.endDay+x.permittedDelay
          color: 'green'
          label: x.id+" ("+x.permittedDelay+")"
    if network
      network.setData { nodes: nodes, edges: edges }
    else
      options =
        edges:
          style: 'arrow'
      network = new vis.Network (document.getElementById 'pert'), { nodes: nodes, edges: connections }, options
  $scope.buildGraph $scope.fromLocalStorage()

pertApp.controller 'ganttDiagController', ($scope) ->
  $scope.toDates = (list, startDay) ->
    list.map (i) ->
      r = content: ""+i.id, id: i.id
      if i.startDay? then r.start = moment(startDay).add(i.startDay, 'days').format 'YYYY-MM-DD'
      if i.endDay? then r.end = moment(startDay).add(i.endDay, 'days').format 'YYYY-MM-DD'
      return r
  $scope.buildTimeline = (data) ->
    if !data? then return
    timeline = new vis.Timeline (document.getElementById 'timeline'), ($scope.toDates data.activities), {}
  $scope.buildTimeline $scope.fromLocalStorage()

pertController = ($scope) ->
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
