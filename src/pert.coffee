chalk = require 'chalk'
fs = require 'fs'

pert = 
  log: (x...) -> if @verbose then console.log chalk.bold("Pert:"), x...
  err: (x...) -> console.log chalk.bold (chalk.red "Pert:"), x...

  # Returns the highest number in an array of numbers
  maxa: (l) -> return Math.max.apply null, l

  # Find the activity with given id
  toActivity: (id,list) ->
    if !list? then pert.err "list is",list
    item = {}
    list.forEach (x) -> if x.id is id then item = x
    return item

  # Find the item 
  calculateEndDay: (item,list) ->
    if !item.startDay?
      pert.log "calculating start day of",item.id
      item.startDay = pert.calculateStartDay item, list
    pert.log "start day of",item.id,"is",item.startDay
    item.endDay = item.startDay + item.duration
    pert.log "end day of",item.id,"is",item.endDay
    return item.endDay

  # Find out which day the activity starts
  calculateStartDay: (item,list) ->
    if !item.depends? or item.depends.length is 0 then return item.startDay = 0
    item.startDay = pert.maxa item.depends.map((x) -> pert.toActivity x,list).map((x) -> pert.calculateEndDay x, list)
    pert.log "start day of",item.id,"is",item.startDay
    # write max delay time to each depend
    item.depends.forEach (x) ->
      pert.log "checking permittedDelay to dependency", x, "of", item
      i = pert.toActivity x, list
      if !i.permittedDelay?
        i.permittedDelay = item.startDay - pert.calculateEndDay i, list
        pert.log "written permittedDelay to dependency", x, "of", item, "as", i.permittedDelay
      else pert.log "aborting permittedDelay: already calculated"
      pert.log "permitted delay of",x,"is",i.permittedDelay
    return item.startDay

  # Find out which activity has the highest id
  highestID: (list) -> return pert.maxa(list.map (x) -> x.id)

  calculate: (list,verbose) ->
    pert.verbose = verbose
    pert.calculateEndDay (pert.toActivity pert.highestID(list), list), list
    return list

module.exports = pert
