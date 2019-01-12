tabs = [
  'settings'
  'screens'
  'html'
  'scripts'
  'css'
]

Template.EditView.onCreated ->
  Session.set 'tab', 'settings'
  Session.set 'script key', null # child will see null until we are ready

Template.EditView.onRendered ->
  # TODO: is this okay to create here?
  @editors =
    html: CodeMirror @$('.html-editor')[0],
      lineNumbers: true
      mode:
        name: 'htmlembedded'
        open: '{{'
        close: '}}'
      theme: 'neo'
      tabSize: 2
      value: @data.view.template.html

    scripts: CodeMirror @$('.script-editor')[0],
      lineNumbers: true
      mode: 'coffeescript'
      theme: 'neo'
      tabSize: 2
      value: '' # '(event) ->\n  # logic goes here'

    css: CodeMirror @$('.css-editor')[0],
      lineNumbers: true
      mode: 'css'
      theme: 'neo'
      tabSize: 2
      value: @data.view.template.css ? 'body {\n  background: #fff;\n}'

  # We are our own page, we have room
  for _, editor of @editors
    editor.setSize null, 400

  # Let the scripting child view access CodeMirror
  @$('.script-editor')[0].cm = @editors.scripts

  # Detect tab and script from URL
  hash = location.hash.slice 1
  [tab, scriptKey] = hash.split '/'
  if tab in tabs
    Session.set 'tab', tab
  if scriptKey
    Session.set 'script key', scriptKey

  # Handle tab/script persistance
  @autorun =>
    tab = Session.get 'tab'
    location.hash = '#' + tab

    if tab is 'scripts'
      if scriptKey = Session.get('script key')
        location.hash += '/' + scriptKey

    # Redraw editor if any, otherwise new ones are blank
    @editors[tab]?.refresh()

  # Init and select tabs
  @$('ul.tabs').tabs()
  @$('a[href="#' + Session.get('tab') + '"]').click()


# TODO: do we need to garbage collect the editors?
# check with chrome profiling tools

Template.EditView.helpers
  tabBody: (tab) ->
    selected = Session.get('tab') is tab
    class: ['tab-body', if selected then 'selected'].join ' '

Template.EditView.events

  # Record tab selection in a reactive way
  'click ul.tabs a': (evt) ->
    evt.preventDefault()
    tab = evt.target.hash.slice 1
    if tab in tabs
      Session.set 'tab', tab

  'click #save-html': (evt) ->
    evt.preventDefault()
    {html} = Template.instance().editors
    Views.update @view._id, $set:
      'template.html': html.getValue()

  'click #save-css': (evt) ->
    evt.preventDefault()
    {css} = Template.instance().editors
    Views.update @view._id, $set:
      'template.css': css.getValue()

####################
## Settings editing

Template.EditView.events
  'click [name=new-setting]': (e) ->
    e.preventDefault()
    Views.update @view._id, $push: settings:
      key: prompt 'Setting key for view'
      label: prompt 'Setting label'
      type: prompt 'Setting type', 'string'
    , (err) -> if err
      alert "Couldn't create view setting.\n\n#{err.name} #{err.message}"

###################
## Screen editing

Template.EditView.helpers
  screens: ->
    Screens.find
      view: @view._id

  screenLink: ->
    Meteor.absoluteUrl "screen-ng/#{@_id}"

  settingTmpl: -> [
    @type[0].toUpperCase()
    @type.slice(1)
    'SettingValue'
  ].join ''

  settingValues: ->
    context =
      type: 'screen'
      id: @_id

    Template.parentData().view.settings.map ({key, type}) =>
      entry = Settings.findOne({key, context})

      {
        value: entry?.value
        extras:
          style: 'margin: 0; height: 2em;'
      context, key, type, entry }

Template.EditView.events
  # Copied pretty directly from settings.coffee
  # Need to reconcile the various settings usages
  'blur input, blur select': (e) ->
    return unless @context and @key
    return unless (value = e.target.value) and value isnt @value

    if @entry
      Settings.update @entry._id, $set: {value}, (err) -> if err
        alert "Problem updating setting\n\n#{err.name} #{err.message}"
      else
        console.log 'setting update ok to', value
    else
      reference = if @type.endsWith 'Id' then @type.slice(0, -2)
      Settings.insert {@context, @key, value, reference}, (err) -> if err
        alert "Problem saving setting\n\n#{err.name} #{err.message}"
      else
        console.log 'setting create ok to', value

  'click a[href="#delete"]': (e) ->
    e.preventDefault()
    return unless confirm "Do you really want to delete #{@name}?"

    Settings.find(context: {type: 'screen', id: @_id}).map (entry) ->
      Settings.remove entry._id

    Data.find(context: {type: 'screen', id: @_id}).map (entry) ->
      Data.remove entry._id

    Displays.find(screen: @_id).map (display) ->
      Displays.update display._id,
        $unset:
          screen: 1
          view: 1

    Screens.remove @_id

  'click a[href="#refresh"]': (e) ->
    e.preventDefault()
    # schedule the screen for an immediate fetching
    Screens.update @_id, $unset:
      expires: true
