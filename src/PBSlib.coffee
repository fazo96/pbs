class PBS
  constructor: (@list, @verbose) ->
    @days = []
    @verbose = yes
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
  calculateEndDay: (item,cb) =>
    if item.endDay? then cb null, item.endDay
    else if !item.startDay?
      @log "calculating start day of",item.id
      @calculateStartDay item, => @calculateEndDay item, cb
    else
      @log "start day of",item.id,"is",item.startDay
      item.endDay = item.startDay + item.duration
      @log "end day of",item.id,"is",item.endDay
      @insertDay item.endDay
      cb null, item.endDay

  # Find out which day the activity starts
  calculateStartDay: (item,cb) =>
    if item.startDay? then cb null, item.startDay
    else if !item.depends? or item.depends.length is 0
      @insertDay 0
      cb null, item.startDay = 0
    else
      async.map item.depends.map(@toActivity), @calculateEndDay.bind(@), (er, r) =>
        item.startDay = @maxa r
        @log "start day of",item.id,"is",item.startDay
        # write max delay time to each depend
        checkPermittedDelay = (x,c) =>
          @log "checking permittedDelay to dependency", x, "of", item
          i = @toActivity x
          if !i.dependant? then i.dependant = [item.id]
          else i.dependant.push item.id
          if !i.permittedDelay?
            @calculateEndDay i, (e,d) =>
              i.permittedDelay = item.startDay - d
              @log "written permittedDelay to dependency", x, "of", item, "as", i.permittedDelay
              @log "permitted delay of",x,"is",i.permittedDelay
              c()
          else
            @log "aborting permittedDelay: already calculated"
            @log "permitted delay of",x,"is",i.permittedDelay
            c()
        async.each item.depends, checkPermittedDelay.bind(@), =>
          @insertDay item.startDay
          cb null, item.startDay

  calculateDelays: (item,cb) =>
    if !item.dependant? or item.dependant.length is 0 then cb null, no
    else
      lowestFDelay = 0; fDelay = no; cDelay = 0
      checkDependant = (i,c) =>
        x = @toActivity i
        if !isNaN(x.permittedDelay) or x.permittedDelay < lowestFDelay or fDelay is no
          @log "activity", i, "dependant on", item.id, "has the lowest delay for now ("+(x.permittedDelay or 0)+")"
          lowestFDelay = x.permittedDelay or 0
          cDelay = x.chainedDelay or 0
          fDelay = yes
          c()
      async.each item.dependant, checkDependant.bind(@), =>
        olDelay = item.chainedDelay
        item.chainedDelay = lowestFDelay + cDelay
        @log "chained delay of", item.id, "is", item.chainedDelay
        cb null, item.chainedDelay isnt olDelay

  calculateCriticalPaths: (path,cb) ->
    @log "calculating path from",path
    lastID = path[path.length - 1]
    last = @toActivity lastID
    if last.dependant? and last.dependant.length > 0
      checkDependant = (x,cb2) =>
        ii = @toActivity x
        delay = ii.permittedDelay or 0
        if delay is 0
          cb2 null, yes
          @calculateCriticalPaths path.concat(x), cb
        else
          @log "dead end at", lastID, "-->", x, "because delay is", delay
          cb2 null, no
      async.each last.dependant, checkDependant.bind(@), (a,b) -> return
    else
      setCritical = (x,c) =>
        @toActivity(x).critical = yes
        c null, yes
      async.each path, setCritical.bind(@), =>
        @log "calculated path", path
        @criticalPaths.push path
        cb null, path

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
    @log "(Step 1) calculating startDay, endDay, freeDelay"
    async.each @list, @calculateEndDay.bind(@), =>
      @log "(Step 2) Starting chained delay calculations."
      cont = yes; i = 0
      notDone = ->
        console.log cont
        cont
      chainedDelayChanged = (x,res) =>
        i++
        cont = no
        @calculateDelays x, (e,r) =>
          @log "cDelay calc result:",r
          res null, r
      calculateAllDelays = (cb2) =>
        async.map @list, chainedDelayChanged, (err,r) ->
          iterator = (acc,x,cb3) ->
            if x
              cb3 null, yes
            else cb3 null, acc
          async.reduce r, no, iterator, (err,res) ->
            cont = res
            cb2 null
      #TODO: check WHILST
      async.whilst notDone, calculateAllDelays, =>
        @log "Done calculating delays. Took", i, "iterations"
        #TODO: check THIS vvvvv
        calculateCriticalPathIfApplicable = (x, c) =>
          if !x.depends? or x.depends.length is 0
            @calculateCriticalPaths [x.id], c
        async.each @list, calculateCriticalPathIfApplicable.bind(@), =>
          results = activities: @list, days: @days, criticalPaths: @criticalPaths
          @log "DONE:", results
          if options?.json
            cb JSON.stringify results
          else
            cb results
