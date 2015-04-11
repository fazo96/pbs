class PBS
  constructor: (obj, @verbose, @errListener) ->
    @days = []
    @resources = []
    @criticalPaths = []
    @verbose = yes
    if obj.push # is a list
      @list = obj
    else if obj.activities
      @list = obj.activities
      if obj.resources?.push? then @resources = obj.resources
    else
      @list = []
      @err 'data is not an array nor a object with "activities" array'

  log: (x...) ->
    if @verbose
      if chalk?
        console.log chalk.bold "[ Pert ]", x...
      else console.log "[ Pert ]", x...
  err: (x...) ->
    if chalk?
      console.log chalk.bold chalk.red("[ Pert ]"), x...
    else console.log "[ !Pert! ]", x...
    if @errListener?.call? then @errListener x
    return x

  # Already Async
  compileResources: =>
    @log 'compiling resources...'
    if not @resources? then return
    @resources.forEach (x) =>
      @log 'processing resource', x
      if x.assignedTo?.push? then x.assignedTo.forEach (i) =>
        a = @toActivity i
        a.assigned ?= []
        a.assigned.push x.name or x.id
    @list.forEach (x) =>
      item = @toActivity x
      if item.assigned?.push? then item.assigned.forEach (i) =>
        res = @toResource i
        if res
          @log 'found', res, 'assigned to', item
          res.assignedTo ?= []
          res.assignedTo.push i

  # Returns the highest number in an array of numbers
  maxa: (l) -> return Math.max.apply null, l

  # Find the activity with given id
  #TODO: write async version 'withActivity'
  toActivity: (id) =>
    if !@list? then @err "list is", @list
    item = {}
    for i,x of @list
      if x.id is id then item = x
    return item

  # Find the activity with given id
  #TODO: write async version 'withResource'
  toResource: (id) =>
    unless @resources?.push? then return
    item = {}
    for i,x of @resources
      if x.id is id or x.name is id then item = x
    return item

  calculateFreeDelay: (dependencyID,dependantID) =>
    @log "checking freeDelay to dependency", dependencyID, "of", dependantID
    i = @toActivity dependencyID
    dependant = @toActivity dependantID
    if !i.dependant? then i.dependant = [dependant.id]
    else i.dependant.push dependant.id
    if !i.permittedDelay?
      i.permittedDelay = dependant.startDay - @calculateEndDay i
      @log "written permittedDelay to dependency", dependencyID, "of", dependant, "as", i.permittedDelay
    else @log "aborting permittedDelay: already calculated"
    @log "permitted delay of",dependencyID,"is",i.permittedDelay

  # Find out which day the activity starts
  calculateStartDay: (item) =>
    if !item.depends? or item.depends.length is 0
      @insertDay 0
      return item.startDay = 0
    item.startDay = @maxa item.depends.map(@toActivity).map @calculateEndDay
    @log "start day of",item.id,"is",item.startDay
    # write max delay time to each depend
    for j,x of item.depends
      @calculateFreeDelay x, item.id
    @insertDay item.startDay
    return item.startDay

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

  calculateChainedDelays: (item) =>
    if !item.dependant? or item.dependant.length is 0 then return no
    olDelay = item.chainedDelay
    if item.critical
      @log item.id, 'is critical: no chained delays'
      item.chainedDelay = 0
    else
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
    if last.permittedDelay > 0
      @log "dead end at", lastID, "because its delay is", last.permittedDelay
    else if last.dependant? and last.dependant.length > 0
      last.dependant.forEach (x) =>
        ii = @toActivity x
        delay = ii.permittedDelay or 0
        if delay is 0
          @log 'following path from', last.id, 'to', ii.id, 'because', ii, 'has', ii.permittedDelay, 'days of free delay'
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

  calculateEndDays: =>
    for x,i in @list
      @log 'StartDay, EndDay for ('+i+'/'+@list.length+')'
      @calculateEndDay x

  calculateAllCriticalPaths: =>
    for x,i in @list
      if !x.depends? or x.depends.length is 0
        @calculateCriticalPaths [x.id]

  calculateAllChainedDelays: =>
    finished = no; i = 0
    while !finished
      i++; finished = yes
      for x,i in @list
        if @calculateChainedDelays x
          finished = no
    @log "Done calculating chained delays. Took", i, "iterations"

  calculate: (options,cb) ->
    #if !cb? or !cb.call?
    #return @err 'calculate called without callback'
    # Calculate startDay, endDay, freeDelay
    @calculateEndDays()
    # Calculate Critical Paths
    @calculateAllCriticalPaths()
    # Calculate chained Delays
    @calculateAllChainedDelays()
    # Compile resource information
    @compileResources()
    # done
    results =
      activities: @list
      days: @days
      criticalPaths: @criticalPaths
      resources: @resources || []
    @log 'Done', results
    if options?.json
      if cb?.call?
        cb null, JSON.stringify results
      else return JSON.stringify results
    else
      if cb?.call?
        cb null, results
      else return results
