root.ViewService =
class ViewService
  constructor: (@id, {@name, @module, fetcher}) ->
    @threads = {}
    @context =
      type: 'module'
      id: @module
    @setLauncher fetcher

    Screens.find {view: @id},
      fields:
        name: 1
    .observeChanges
      added: (id, fields) =>
        @startScreen id, fields
      changed: (id, fields) =>
        if 'name' of fields
          @threads[id]?.name = fields.name
      removed: (id) =>
        @stopScreen(id)

  setLauncher: (fetcher) ->
    @stop()
    try
      @log 'Compiling'
      @launcher = eval Meteor.call 'compileCoffee', fetcher, 'block'
      @start()
    catch ex
      @log 'Error while compiling:', ex.stack

  start: ->
    for id, thread of @threads
      thread.start()

  startScreen: (id, {name}) ->
    @stopScreen(id) # just in case
    @threads[id] = new Thread(@, name, id)
    @threads[id].start()

  stop: ->
    for id, thread of @threads
      thread.stop()

  stopScreen: (id) ->
    @threads[id]?.stop()
    delete @threads[id]


  ################
  ## For logging

  log: (msg...) ->
    console.log "[#{@fullName()}]", msg...

  setName: (@name) ->
  fullName: ->
    ['view', @name].join('#')
  fullNameOf: (id) ->
    ['view', @name, @threads[id]?.name].join('#')


  ################
  ## For threads
  # TODO: warn when not in fiber

  getSetting: (id, key, defVal) ->
    Settings.findOne({context: @contextOf(id), key})?.value ?
      Settings.findOne({@context, key})?.value ?
      defVal

  getSettings: (id) ->
    dict = {}
    Settings.find({@context}).forEach (s) ->
      dict[s.key] = s.value
    Settings.find(context: @contextOf(id)).forEach (s) ->
      dict[s.key] = s.value
    return dict

  getData: (id, key, defVal) ->
    Data.findOne({context: @contextOf(id), key})?.value ?
      Data.findOne({@context, key})?.value ?
      defVal

  setData: (id, key, value) ->
    Data.upsert {context: @contextOf(id), key}, $set: {value}

  contextOf: (id) ->
    type: 'screen'
    id: id