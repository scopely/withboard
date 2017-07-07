# Bind session to local storage
bootstrapped = false
bootstrap = -> if Meteor.isClient and not bootstrapped
  if token = localStorage.getItem 'screen ng token'
    Session.set 'screen ng token', token

  # We are reactive, so completely escape that
  # Otherwise route changes remove this hook
  Tracker.nonreactive ->
    Tracker.autorun ->
      if token = Session.get 'screen ng token'
        localStorage.setItem 'screen ng token', token
      else
        localStorage.removeItem 'screen ng token'
      console.log 'Set token to', token

  # TODO: Maybe we want to unset this sometime
  $('html').attr 'id', 'display'
           .addClass 'tv'

  bootstrapped = true

# TODO: for migration only
Router.route '/display/:whatever', ->
  @redirect '/display'

Router.route '/display',
  template: 'DisplayNg'
  subscriptions: ->
    bootstrap()
    console.log 'token:', Session.get 'screen ng token'
    if token = Session.get 'screen ng token'
      {pane} = Iron.Location.get().queryObject
      Meteor.subscribe '/ng/display', token, pane,
        onStop: (err) -> if err
          console.log 'Display subscription', err.name, err.message
          if err.error is 404
            Session.set 'screen ng token', false
    else
      Meteor.subscribe '/ng/pair'

Router.route '/screen-ng/:id',
  template: 'DisplayNgScreen'
  waitOn: ->
    Meteor.subscribe '/screens/get', @params.id, @params.token
  action: ->
    if screen = Screens.findOne(@params.id, fields: {view: 1})
      Session.set 'view id', screen.view # for reactive CSS
      if template = compileView screen.view

        # TODO: restrict context?
        settings = {}
        Settings.find().forEach ({key, value}) ->
          settings[key] = value

        data = (key) ->
          Data.findOne({key})?.value
        Template[template].onCreated ->
          @getData = data

        @render template,
          data: {settings, data}
      else
        @render 'DisplayNgPairing',
          data: code: '??'
    else
      @render 'DisplayNgPairing',
        data: code: '...'
