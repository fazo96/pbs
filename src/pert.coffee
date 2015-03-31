class Pert
  constructor: (@list, @verbose) ->
    @days = []

  log: (x...) -> if @verbose then console.log chalk.bold("Pert:"), x...
  err: (x...) -> console.log chalk.bold (chalk.red "Pert:"), x...

  # Returns the highest number in an array of numbers
  maxa: (l) -> return Math.max.apply null, l

  # Find the activity with given id
  toActivity: (id) =>
    if !@list? then @err "list is", @list
    item = {}
    @list.forEach (x) -> if x.id is id then item = x
    return item

  # Compute the item's end day 
  calculateEndDay: (item) =>
    if !item.startDay?
      @log "calculating start day of",item.id
      item.startDay = @calculateStartDay item
    @log "start day of",item.id,"is",item.startDay
    item.endDay = item.startDay + item.duration
    @log "end day of",item.id,"is",item.endDay
    @insertDay item.endDay
    return item.endDay

  # Find out which day the activity starts
  calculateStartDay: (item) =>
    if !item.depends? or item.depends.length is 0
      @insertDay 0
      return item.startDay = 0
    item.startDay = @maxa item.depends.map(@toActivity).map @calculateEndDay
    @log "start day of",item.id,"is",item.startDay
    # write max delay time to each depend
    item.depends.forEach (x) =>
      @log "checking permittedDelay to dependency", x, "of", item
      i = @toActivity x
      if !i.dependant? then i.dependant = [item.id]
      else i.dependant.push item.id
      if !i.permittedDelay?
        i.permittedDelay = item.startDay - @calculateEndDay i
        @log "written permittedDelay to dependency", x, "of", item, "as", i.permittedDelay
      else @log "aborting permittedDelay: already calculated"
      @log "permitted delay of",x,"is",i.permittedDelay
    @insertDay item.startDay
    return item.startDay

  # Find out which activity has the highest id
  highestID: => return @maxa(@list.map (x) -> x.id)

  # Insert a day to the list of days if it's not there already
  insertDay: (day) =>
    for d in @days
      if day is d then return
    @days.push day

  setData: (data) ->
    @list = data
    return @

  calculate: (options,cb) ->
    h = @highestID()
    @list.forEach (x) =>
      @log '('+x.id+'/'+h+')'
      @calculateEndDay x
    results = activities: @list, days: @days
    if options?.json
      if cb? then cb(JSON.stringify results)
      JSON.stringify results
    else
      if cb? then cb(results)
      results

if module? then module.exports = Pert
