tableController = ($scope,getList) ->
  $scope.list = []
  $scope.refreshTable = ->
    data = $scope.fromLocalStorage()
    if data?
      $scope.list = getList data
  $scope.$on 'dataChanged', $scope.refreshTable
  $scope.refreshTable()


pertApp.controller 'tableController', ($scope) ->
  tableController $scope, (data) -> data.activities or []
pertApp.controller 'resourceTableController', ($scope) ->
  tableController $scope, (data) -> data.resources or []
pertApp.controller 'pertDiagController', ($scope) ->
  $scope.buildGraph = (data) ->
    if !data? then return
    nodes = data.days.map (x) -> {id: x, label: ""+x}
    connections = []
    data.activities.forEach (x) ->
      maxDuration = x.duration + (x.permittedDelay or 0) + (x.chainedDelay or 0)
      connections.push
        from: x.startDay, to: x.endDay
        label: x.id+" ("+(if maxDuration isnt x.duration then x.duration+"/"+maxDuration else x.duration)+")"
        color: if x.critical then 'red' else if !x.permittedDelay then 'orange'
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
  $scope.rebuild = ->
    $scope.buildGraph $scope.fromLocalStorage()
  $scope.$on 'dataChanged', $scope.rebuild
  $scope.rebuild()

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

areYouSure = (text,cb) ->
    swal {
      title: "Are you sure?"
      text: text
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes"
      closeOnConfirm: yes
    }, cb

pertApp.controller 'rawEditorController', ($scope) ->
  $scope.reset = (askConfirm) ->
    doIt = -> $scope.toLocalStorage { activities: [], resources: [] }
    if askConfirm
      areYouSure "ALL data will be lost!", doIt
    else doIt()
  $scope.saveData = (askConfirm) ->
    try
      data = JSON.parse $scope.taData
    catch e
      return swal 'Invalid Data', e, 'error'
    doIt = -> $scope.toLocalStorage data
    if askConfirm then areYouSure "Current saved data will be replaced by the data in the RawEditor", doIt
    else doIt()
  $scope.reloadData = (askConfirm) ->
    doIt = ->
      $scope.taData = JSON.stringify $scope.fromLocalStorage silent: yes, raw: yes
    if askConfirm then areYouSure "Current saved data will be replaced by the data in the RawEditor", doIt
    else doIt()
  $scope.$on 'dataChanged', $scope.reloadData
  $scope.reloadData()

pertApp.controller 'editorController', ($scope) ->
  $scope.activities = []
  $scope.resources = []
  $scope.actID = ''; $scope.actDur = ''; $scope.actDeps = ''
  $scope.resID = ''; $scope.resName = ''; $scope.resAss = ''
  $scope.clone = (isResource, id) ->
    data = $scope.fromLocalStorage({raw: yes, silent: yes})
    l = if isResource then data.resources else data.activities
    for i,j of $scope.fromLocalStorage({raw: yes, silent: yes}).activities
      if j.id is id
        $scope.addNew j.id, j.duration, j.depends
        swal 'Ok', id+' has been cloned', 'success'
        return
    swal 'Ops', 'could not find '+id, 'warning'

  $scope.delete = (isResource, index,id) ->
    newdata = $scope.fromLocalStorage raw: yes
    iter = if isResource then newdata.resources else newdata.activities
    l = []
    if id? then for i,j of iter
      if id isnt j.id and id isnt j.name
        l.push j
    else for i,j of iter
      if parseInt(i) isnt index
        l.push j
    diff = iter.length - l.length
    if isResource
      newdata.resources = l
    else newdata.activities = l
    $scope.toLocalStorage newdata, silent: yes
    if diff isnt 1
      swal 'Done', diff+' item(s) deleted', 'warning'

  $scope.addNew = (isResource, id, dur, deps) ->
    dur ?= if isResource then $scope.resName else $scope.actDur
    id ?= if isResource then $scope.resID else $scope.actID
    if !deps?
      deps = if isResource then $scope.resAss else $scope.actDeps
      deps = deps.split ' '
      if deps.length is 1 and deps[0] is ''
        deps = []
    if !isResource
      try
        dur = parseInt dur
      catch e
        return swal 'Error', 'duration must be an integer', 'error'
    try
      unless isNaN id
        id = parseInt id
    for i,dep of deps
      try
        unless isNaN dep
          deps[i] = parseInt dep
      catch e
    newdata = $scope.fromLocalStorage silent: yes, raw: yes
    if isResource
      if newdata?.resources?.push?
        console.log newdata.resources
        newdata.resources.push { id: id, name: dur, assignedTo: deps }
        $scope.toLocalStorage newdata, silent: yes
      else console.log "wtf cant add, data broken"
    else
      if newdata?.activities?.push?
        newdata.activities.push { id: id, duration: dur, depends: deps }
        $scope.toLocalStorage newdata, silent: yes
      else console.log "wtf cant add, data broken"

  
  $scope.refreshEditor = ->
    data = $scope.fromLocalStorage { silent: yes, raw: yes }
    $scope.activities = data.activities || []
    $scope.resources = data.resources || []
  $scope.$on 'dataChanged', $scope.refreshEditor
  $scope.refreshEditor()
