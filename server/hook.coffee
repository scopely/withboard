Router.route '/hooks/:type/:id/:hook', ->
  # fetch screen hook service
  screen = Screens.findOne @params.id
  service = new HookService screen

  # run task thread for hook
  thread = service.newThread @params.hook, @params
  thread.start()
  thread.log 'All good'

  @response.end 'all good\n'
, where: 'server'

class HookService
  constructor: (@screen) ->
    @view = Views.findOne @screen.view
    @module = Modules.findOne @view.module

    @contextModule =
      type: 'module'
      id: @module._id
    @contextScreen =
      type: 'screen'
      id: @screen._id

  log: (msg...) ->
    console.log "[#{@fullName()}]", msg...

  fullName: ->
    ['view', @view.name, @screen.name].join('#')
  fullNameOf: ({hook}) ->
    ['view', @view.name, @screen.name, hook].join('#')

  newThread: (params...) ->
    thread = new Thread @, params...
    thread.hook = params[0]
    thread.screen = @screen
    thread.view = @view
    thread.module = @module
    thread.contextModule = @contextModule
    thread.contextScreen = @contextScreen
    return thread

  # @ is thread
  launcher: ->
    hooks = @view.template.scripts
      .filter ({hook}) -> hook is 'hook'
      .filter ({param}) => param is @hook

    if hooks[0]
      eval(hooks[0].js).apply().apply(@, @args)

  ################
  ## For threads
  # TODO: warn when not in fiber

  getSetting: (id, key, defVal) ->
    Settings.findOne({context: @contextScreen, key})?.value ?
      Settings.findOne({@contextModule, key})?.value ?
      defVal

  getSettings: (id) ->
    dict = {}
    Settings.find({@contextModule}).forEach (s) ->
      dict[s.key] = s.value
    Settings.find(context: @contextScreen).forEach (s) ->
      dict[s.key] = s.value
    return dict

  getData: (id, key, defVal) ->
    Data.findOne({context: @contextScreen, key})?.value ?
      Data.findOne({@contextModule, key})?.value ?
      defVal

  setData: (id, key, value) ->
    Data.upsert {context: @contextScreen, key}, $set: {value}
