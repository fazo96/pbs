console.log 'Pert ui'

$('#ta').val localStorage.getItem 'ganttpert'

$('#save').click ->
  console.log 'save'
  localStorage.setItem 'ganttpert', $('#ta').val()
