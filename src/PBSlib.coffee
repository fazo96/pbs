class PBS
  constructor: (@list, @verbose) ->
    @days = []
    @criticalPaths = []

  log: (x...) ->
    if @verbose
      if chalk?
        console.log chalk.bold "[ Pert ]", x...
      else console.log "[ Pert ]", x...
  err: (x...) ->
    if chalk?
      console.log chalk.bold chalk.red("[ !Pert! ]"), x...
    else console.log "[ !Pert! ]", x...

  # Returns the highest number in an array of numbers
  maxa: (l) -> return Math.max.apply null, l

  # Find the activity with given id
  toActivity: (id) =>
    if !@list? then @err "list is", @list
    item = {}
    for i,x of @list
      if x.id is id then item = x
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
    for j,x of item.depends
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

  calculateDelays: (item) =>
    if !item.dependant? or item.dependant.length is 0 then return no
    lowestFDelay = 0; fDelay = no; cDelay = 0
    for j,i of item.dependant
      x = @toActivity i
      if !isNaN(x.permittedDelay) or x.permittedDelay < lowestFDelay or fDelay is no
        @log "activity", i, "dependant on", item.id, "has the lowest delay for now ("+(x.permittedDelay or 0)+")"
        lowestFDelay = x.permittedDelay or 0
        cDelay = x.chainedDelay or 0
        fDelay = yes
    olDelay = item.chainedDelay
    item.chainedDelay = lowestFDelay + cDelay
    @log "chained delay of", item.id, "is", item.chainedDelay
    return item.chainedDelay isnt olDelay

  calculateCriticalPaths: (path) ->
    @log "calculating path from",path
    lastID = path[path.length - 1]
    last = @toActivity lastID
    if last.dependant? and last.dependant.length > 0
      last.dependant.forEach (x) =>
        ii = @toActivity x
        delay = ii.permittedDelay or 0
        if delay is 0
          @calculateCriticalPaths path.concat x
        else
          @log "dead end at", lastID, "-->", x, "because delay is", delay
    else
      path.forEach (x) => @toActivity(x).critical = yes
      @log "calculated path", path
      @criticalPaths.push path

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
    for x,i in @list
      @log '('+x.id+'/'+h+')'
      @calculateEndDay x
    finished = no; i = 0
    while !finished
      i++; finished = yes
      for x,i in @list
        if @calculateDelays x
          finished = no
    @log "Done calculating delays. Took", i, "iterations"
    for x,i in @list
      if !x.depends? or x.depends.length is 0
        @calculateCriticalPaths [x.id]
    results = activities: @list, days: @days, criticalPaths: @criticalPaths
    if options?.json
      if cb? then cb(JSON.stringify results)
      JSON.stringify results
    else
      if cb? then cb(results)
      results
