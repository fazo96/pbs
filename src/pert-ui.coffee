console.log 'Pert ui'

toDates = (list, startDay) ->
  list.map (i) ->
    r = content: ""+i.id, id: i.id
    if i.startDay? then r.start = moment(startDay).add(i.startDay, 'days').format 'YYYY-MM-DD'
    if i.endDay? then r.end = moment(startDay).add(i.endDay, 'days').format 'YYYY-MM-DD'
    return r

buildTimeline = (data) ->
  timeline = new vis.Timeline (document.getElementById 'timeline'), (toDates data.activities), {}

buildGraph = (data) ->
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

fromLocalStorage = ->
  data = localStorage.getItem 'ganttpert'
  if data
    try
      jdata = JSON.parse data
    catch e
      return swal 'JSON Error', e, 'error'
    if jdata
      buildGraph new Pert(jdata).calculate()
    else return swal 'Error', 'no JSON?', 'error'
  else swal 'Error', 'no data to parse', 'error'

fromLocalStorage()