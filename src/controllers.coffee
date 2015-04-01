pertApp.controller 'tableController', ($scope) ->
  $scope.list = []
  $scope.refreshTable = ->
    ls = $scope.fromLocalStorage()
    if ls?
      $scope.list = ls.activities
  $scope.$on 'dataChanged', $scope.refreshTable
  $scope.refreshTable()

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
      network = new vis.Network (document.getElementById 'pertDiagram'), { nodes: nodes, edges: connections }, options
  $scope.$on 'dataChanged', ->
    $scope.buildGraph $scope.fromLocalStorage()
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
  $scope.$on 'dataChanged', ->
    $scope.buildTimeline $scope.fromLocalStorage()
  $scope.buildTimeline $scope.fromLocalStorage()

pertApp.controller 'rawEditorController', ($scope) ->
  $scope.saveData = ->
    try
      data = JSON.parse $scope.taData
    catch e
      return swal 'Error', 'The data entered is invalid', 'error'
    $scope.toLocalStorage data
  $scope.reloadData = ->
    $scope.taData = JSON.stringify $scope.fromLocalStorage silent: yes, raw: yes
  $scope.$on 'dataChanged', ->
    $scope.reloadData()
    #$('#ta').val JSON.stringify $scope.fromLocalStorage silent: yes, raw: yes
  $scope.reloadData()

pertApp.controller 'editorController', ($scope) ->
  $scope.list = []
  $scope.clone = (id) ->
    for i,j of $scope.fromLocalStorage({raw: yes, silent: yes})
      if j.id is id
        $scope.addNew j.id, j.duration, j.depends
        swal 'Ok', id+' has been cloned', 'success'
        return
    swal 'Ops', 'could not find '+id, 'warning'

  $scope.delete = (index,id) ->
    newdata = $scope.fromLocalStorage raw: yes
    l = []
    if id? then for i,j of newdata
      if id isnt j.id
        l.push j
    else for i,j of newdata
      if parseInt(i) isnt index
        l.push j
    diff = newdata.length - l.length
    $scope.toLocalStorage l, silent: yes
    if diff isnt 1
      swal 'Done', diff+' item(s) deleted', 'warning'

  $scope.addNew = (id, dur, deps) ->
    dur ?= $('#new-duration').val().trim()
    id ?= $('#new-id').val().trim()
    if !deps?
      deps = $('#new-deps').val().split(' ')
      if deps.length is 1 and deps[0] is ''
        deps = []
    try
      dur = parseInt dur
    catch e
      return swal 'Error', 'duration must be an integer', 'error'
    try
      id = parseInt id
    catch e
      return
    for i,dep of deps
      try
        deps[i] = parseInt dep
      catch e
        return
    newdata = $scope.fromLocalStorage silent: yes, raw: yes
    newdata.push { id: id, duration: dur, depends: deps }
    $scope.toLocalStorage newdata, silent: yes
  
  $scope.refreshEditor = ->
    data = $scope.fromLocalStorage { silent: yes, raw: yes }
    $scope.list = data || []
  $scope.$on 'dataChanged', $scope.refreshEditor
  $scope.refreshEditor()
