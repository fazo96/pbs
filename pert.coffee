#!/usr/bin/env coffee

console.log "pert"

list = [{id: 0, depends: [], duration: 2}, { id: 1, depends: [0], duration: 3},{id: 2, depends: [0,1], duration: 4}]

maxa = (l) -> return Math.max.apply null, l

# Find the activity with given id
toActivity = (id) ->
  item = {}
  list.forEach (x) -> if x.id is id then item = x
  return item

# Find the item 
calculateEndDay = (item) ->
  if !item.startDay?
    console.log "calculating start day of",item.id
    item.startDay = calculateStartDay item
  console.log "Start day of",item.id,":",item.startDay
  item.endDay = item.startDay + item.duration
  console.log "End Day of",item.id,":",item.endDay
  return item.endDay

# Find out which day the activity starts
calculateStartDay = (item) ->
  if item.depends.length is 0 then return item.startDay = 0
  console.log "Deps:",item.depends.map(toActivity)
  console.log "EndDays:",item.depends.map(toActivity).map(calculateEndDay)
  max = maxa item.depends.map(toActivity).map(calculateEndDay)
  console.log max
  # write max delay time to each depend
  item.depends.forEach (x) ->
    console.log "Writing permittedDelay to dependency", x
    i = toActivity x
    i.permittedDelay = max - calculateEndDay(i)
  return item.startDay = max

# Find out which activity has the highest id
highestID = -> return maxa(list.map (x) -> x.id)

calculate = ->
  calculateEndDay toActivity(highestID())
  list.forEach (x) -> if !x.permittedDelay? then x.final = true
  return list

console.log calculate()
