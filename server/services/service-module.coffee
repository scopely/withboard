root.ModuleService =
class ModuleService
  constructor: (@id, {@name, fetcher}) ->
    @context =
      type: 'module'
      id: @id
    @setLauncher fetcher

  setLauncher: (fetcher) ->
    @stop()
    try
      @log 'Compiling'
      @launcher = eval Meteor.call 'compileCoffee', fetcher, 'block'
      @start()
    catch ex
      @log 'Error while compiling:', ex.stack

  start: ->
    @thread = new Thread @, @name
    @thread.start()

  stop: ->
    @thread?.stop()
    @thread = null


  ################
  ## For logging

  log: (msg...) ->
    console.log "[#{@fullName()}]", msg...

  setName: (@name) ->
    @thread?.name = @name
  fullName: ->
    ['module', @name].join('#')
  fullNameOf: -> @fullName()


  ################
  ## For threads

  getSetting: (key, defVal) ->
    Settings.findOne({@context, key})?.value ? defVal

  getSettings: ->
    dict = {}
    Settings.find({@context}).forEach (s) ->
      dict[s.key] = s.value
    return dict

  getData: (key, defVal) ->
    Data.findOne({@context, key})?.value ? defVal

  setData: (key, value) ->
    Data.upsert {@context, key}, $set: {value}
