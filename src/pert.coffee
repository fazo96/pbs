#!/usr/bin/env coffee
chalk = require 'chalk'
cli = require 'commander'
fs = require 'fs'

log = (x...) -> if cli.verbose then console.log chalk.bold("Log:"), x...
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
  if !item.depends? or item.depends.length is 0 then return item.startDay = 0
  item.startDay = maxa item.depends.map((x) -> toActivity x,list).map((x) -> calculateEndDay x, list)
  log "start day of",item.id,"is",item.startDay
  # write max delay time to each depend
  item.depends.forEach (x) ->
    log "checking permittedDelay to dependency", x, "of", item
    i = toActivity x, list
    if !i.permittedDelay?
      i.permittedDelay = item.startDay - calculateEndDay i, list
      log "written permittedDelay to dependency", x, "of", item, "as", i.permittedDelay
    else log "aborting permittedDelay: already calculated"
    log "permitted delay of",x,"is",i.permittedDelay
  return item.startDay

# Find out which activity has the highest id
highestID = (list) -> return maxa(list.map (x) -> x.id)

calculate = (list) ->
  calculateEndDay (toActivity highestID(list), list), list
  return list

ex = [{id: 0, depends: [], duration: 2}, { id: 1, depends: [0], duration: 3},{id: 2, depends: [0,1], duration: 4}]

cli
  .version '0.1'
  .usage 'loads activity data from JSON and computes the possible activity delays'
  .option '--verbose', 'be verbose (for debugging)'

didSomething = no

cli
  .command 'example'
  .description 'show an example of the JSON data format'
  .action ->
    didSomething = yes
    console.log chalk.bold.green('Before:'), ex
    console.log chalk.bold.green('After calculations:'), calculate ex
    console.log chalk.green 'Tip:',chalk.bold 'optional fields can be freely included in the input data'

cli
  .command 'calculate <file>'
  .description 'calculate data on given JSON document'
  .alias 'c'
  .option '-j, --json', 'output json data'
  .action (file,options) ->
    didSomething = yes
    fs.readFile file, (error,content) ->
      if error then err error
      else
        if options.json then console.log JSON.stringify (calculate JSON.parse(content))
        else console.log calculate JSON.parse(content)

cli.parse process.argv

if !didSomething then console.log chalk.green('Tip:'), 'see', chalk.bold(cli.name()+' --help')
