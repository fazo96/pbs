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
      network = new vis.Network (document.getElementById 'pertDiagram'), { nodes: nodes, edges: connections }, options
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

pertApp.controller 'editorController', ($scope) ->
  $scope.clone = (id) ->
    for i,j of $scope.fromLocalStorage().activities
      console.log j
      if j.id is id
        $scope.addNew j.id, j.duration, j.depends
        swal 'Ok', id+' has been cloned', 'success'
        return
    swal 'Ops', 'could not find '+id, 'warning'
  $scope.delete = (id) ->
    rawdata = localStorage.getItem 'ganttpert'
    try
      newdata = JSON.parse rawdata
    catch e
      swal 'Error', e, 'error'
    if newdata
      l = []
      for i,j of newdata
        if j.id isnt id
          l.push j
      localStorage.setItem 'ganttpert', JSON.stringify l
      swal 'Ok', 'done', 'success'
  $scope.addNew = (id, dur, deps) ->
    ndur = dur || $('#new-duration').val()
    nid = id || $('#new-id').val()
    ndeps = deps || []
    rawdata = localStorage.getItem 'ganttpert'
    try
      newdata = JSON.parse rawdata
    catch e
      swal 'Error', e, 'error'
    newdata.push {id: nid, duration: dur, depends: ndeps}
    $scope.toLocalStorage newdata
  data = $scope.fromLocalStorage()
  if data? then $scope.list = data.activities
