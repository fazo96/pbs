$.get 'data', (d) ->
  # Serve the server data
  list = d
  console.log list
  buildGraph list

buildGraph = (data) ->
  nodes = data.days.map (x) -> {id: x, label: ""+x}
  connections = []
  data.activities.forEach (x) ->
    connections.push
      from: x.startDay, to: x.endDay
      label: x.id+" ("+(if x.permittedDelay > 0 then x.duration+"/"+(x.duration+x.permittedDelay) else x.duration)+")"
    if x.permittedDelay > 0
      connections.push
        from: x.endDay
        to: x.endDay+x.permittedDelay
        color: 'green'
        label: x.id+" ("+x.permittedDelay+")"
  console.log nodes
  console.log connections
  if network
    network.setData { nodes: nodes, edges: edges }
  else
    options =
      edges:
        style: 'arrow'
    network = new vis.Network (document.getElementById 'pert'), { nodes: nodes, edges: connections }, options
