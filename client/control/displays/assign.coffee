Template.ControlAssignDisplay.events
  'change select[name=view]': (event) ->
    selectedView = event.target.value
    {viewId, screenId} = Template.instance()

    viewId.set selectedView
    if screen = Screens.findOne(view: selectedView)
      # There's already at least one screen, show the list
      screenId.set screen._id
    else
      # Otherwise user should make one now
      screenId.set 'new'

  'change select[name=screen]': (event) ->
    selectedView = event.target.value
    {screenId} = Template.instance()

    # Show extra UI, but only if "new" is selected
    if selectedView is 'new'
      screenId.set 'new'
    else
      screenId.set selectedView._id

  'submit form[name=new-screen]': (event) ->
    event.preventDefault()
    {viewId, screenId} = Template.instance()
    return unless view = Views.findOne viewId.get()
    display = @_id

    Screens.insert
      view: viewId.get()
      name: event.target.name.value
    , (err, screen) -> if err
      console.log 'Screen insert error:', err
      alert 'Screen problem: ' + err.stack
    else
      console.log 'Created screen', screen, 'of view', viewId.get()

      # Create any additional setting values
      for {key, label} in view.settings
        if value = event.target['setting_' + key]?.value
          Settings.insert
            context:
              type: 'screen'
              id: screen
            key: key
            value: value
          , (err, settingId) -> if err
            console.log 'Setting', key, 'of screen', screen, 'insert error:', err
            alert 'Problem with setting ' + key + ': ' + err.stack
            # TODO: note screen still was created
          else
            console.log 'Created setting', key, 'for screen', screen

      # Switch to the new screen
      screenId.set screen
      Displays.update display, $set:
        screen: screen
        view: screen.view

  'submit form[name=assign-screen]': (event) ->
    event.preventDefault()
    screen = event.target.screen.value

    Displays.update @_id, $set:
      screen: screen
      view: Screens.findOne(screen).view
    , (err) => if err
      alert 'Problem with assigning screen: ' + err.stack
      console.log 'Assigning', screen, 'to', @_id, 'error:', err

  # Assign to secondary surfaces (panes) for 4-up
  'click .assign-pane': (event) ->
    event.preventDefault()
    pane = event.target.dataset.pane
    screen = event.target.parentElement.screen.value

    Displays.update @_id, $set:
      "panes.#{pane}":
        screen: screen
        view: Screens.findOne(screen).view
    , (err) => if err
      alert 'Problem with assigning screen: ' + err.stack
      console.log 'Assigning', screen, 'to', @_id, 'pane', pane, 'error:', err


#<button class="btn waves-effect waves-light assign-pane" data-pane="topRight">⬈</button>

Template.ControlAssignDisplay.helpers
  modules: -> Modules.find()
  views: -> Views.find module: @_id
  view: ->
    {viewId} = Template.instance()
    Views.findOne viewId.get()

  viewMaybeSelected: ->
    {viewId} = Template.instance()
    return viewId.get() is @_id

  screenMaybeSelected: ->
    {screenId} = Template.instance()
    return screenId.get() is @_id

  newScreen: ->
    {screenId} = Template.instance()
    screenId.get() is 'new'

  screens: ->
    {viewId} = Template.instance()
    Screens.find view: viewId.get()
  screen: ->
    {screenId} = Template.instance()
    Screens.findOne screenId.get()

  settings: ->
    {viewId, screenId} = Template.instance()
    if view = Views.findOne viewId.get()
      view.settings.map ({key, label, type}) ->
        entry = Settings.findOne
          context:
            type: 'screen'
            id: screenId.get()
          key: key
        value = entry?.value
        {key, label, type, entry, value}

  settingTmpl: -> [
    @type[0].toUpperCase()
    @type.slice(1).toLowerCase()
    'SettingValue'
  ].join ''

  settingData: ->
    key: @key
    type: @type
    value: @value
    extras:
      name: 'setting_' + @key

Template.ControlAssignDisplay.onCreated ->
  @screenId = new ReactiveVar @data.screen
  @viewId = new ReactiveVar

  if screen = Screens.findOne @data.screen
    @viewId.set screen.view
