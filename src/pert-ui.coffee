$.get 'data', (data) ->
  console.log data
  i = 0
  nodes = data.days.map (x) -> {id: x, label: ""+x}
  connections = []
  data.activities.forEach (x) ->
    connections.push
      from: x.startDay, to: x.endDay
      label: x.id+" ("+(if x.permittedDelay > 0 then x.duration+"/"+(x.duration+x.permittedDelay) else x.duration)+")"
    if x.permittedDelay > 0
      connections.push from: x.endDay, to: x.endDay+x.permittedDelay, color: 'green', label: "("+x.permittedDelay+")"
  console.log nodes
  console.log connections
  options =
    edges:
      style: 'arrow'
  network = new vis.Network (document.getElementById 'pert'), { nodes: nodes, edges: connections }, options
