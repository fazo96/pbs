#!/usr/bin/env coffee
chalk = require 'chalk'

verbose = no

log = (x...) -> if verbose then console.log chalk.bold("Log:"), x...
err = (x...) -> console.log chalk.bold (chalk.red "Error:"), x...

# Returns the highest number in an array of numbers
maxa = (l) -> return Math.max.apply null, l

# Find the activity with given id
toActivity = (id,list) ->
  if !list? then err "list is",list
  item = {}
  list.forEach (x) -> if x.id is id then item = x
  return item

# Find the item 
calculateEndDay = (item,list) ->
  if !item.startDay?
    log "calculating start day of",item.id
    item.startDay = calculateStartDay item, list
  log "start day of",item.id,"is",item.startDay
  item.endDay = item.startDay + item.duration
  log "end day of",item.id,"is",item.endDay
  return item.endDay

# Find out which day the activity starts
calculateStartDay = (item,list) ->
  if item.depends.length is 0 then return item.startDay = 0
  max = maxa item.depends.map((x) -> toActivity x,list).map((x) -> calculateEndDay x, list)
  log "start day of",item.id,"is",max
  # write max delay time to each depend
  item.depends.forEach (x) ->
    log "writing permittedDelay to dependency", x, "of", item
    i = toActivity x, list
    i.permittedDelay = max - calculateEndDay i, list
    log "permitted delay of",x,"is",i.permittedDelay
  return item.startDay = max

# Find out which activity has the highest id
highestID = (list) -> return maxa(list.map (x) -> x.id)

calculate = (list) ->
  calculateEndDay (toActivity highestID(list), list), list
  return list

ex = [{id: 0, depends: [], duration: 2}, { id: 1, depends: [0], duration: 3},{id: 2, depends: [0,1], duration: 4}]
console.log calculate ex
