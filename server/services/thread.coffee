root.Thread =
class Thread
  constructor: (@service, @name, @args...) ->
    @status = 'stopped'

    @fullName = @service.fullNameOf.bind @service, @args...
    @getSetting = @service.getSetting.bind @service, @args...
    @getSettings = @service.getSettings.bind @service, @args...
    @getData = @service.getData.bind @service, @args...
    @setData = @service.setData.bind @service, @args...

  start: ->
    @stop()

    unless @service.launcher
      @status = 'missing-code'
      @log 'No launcher to start with'
      return

    @status = 'starting'
    @log 'Starting'

    try
      @service.launcher.apply(@, @args)

      @status = 'running'
      @log 'Ready'
      return @
    catch ex
      console.log 'thread launch err:', ex
      @status = 'crashed'
      @log 'Crashed'

  onStop: (@stopper) ->
    @status = 'running'

  stop: -> if @stopper
    @log 'Stopping'
    @status = 'stopping'
    @stopper()

    @status = 'stopped'
    @stopper = null

  log: (msg...) ->
    console.log "[#{@fullName()}]", msg...
