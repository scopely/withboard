Template.Settings.helpers
  settingTmpl: -> [
    @type[0].toUpperCase()
    @type.slice(1)
    'SettingValue'
  ].join ''

  #settable: ->
    #console.log 's', Template.currentData()
    #Template.currentData().settable

  settings: ->
    context =
      type: @contextType
      id: @id

    (@settings ? []).map (setting) ->
      setting.entry = Settings.findOne({context, key: setting.key})
      setting.value = setting.entry?.value
      setting.extras =
        style: 'height: 2rem; margin: 0;'
        placeholder: '(unset)'
      setting

Template.Settings.events
  'blur input, blur select': (e) ->
    if (value = e.target.value) and value isnt @value
      if @entry
        Settings.update @entry._id, $set: {value}, (err) -> if err
          alert "Problem updating setting\n\n#{err.name} #{err.message}"
        else
          console.log 'setting update ok to', value
      else
        {contextType, id} = Template.currentData()
        context = { type: contextType, id }

        reference = if @type.endsWith 'Id' then @type.slice(0, -2)
        Settings.insert {context, @key, value, @reference}, (err) -> if err
          alert "Problem saving setting\n\n#{err.name} #{err.message}"
        else
          console.log 'setting create ok to', value


#####################################################
# User ID selector (to inherit Google credentials)

Template.UserIdSettingValue.helpers
  # Provide user list
  users: ->
    Meteor.users.find()

Template.UserIdSettingValue.onRendered ->
  # Force state to reflect data store
  @autorun =>
    if userId = Template.currentData().value
      @$('select').val userId

#####################################################
# Screen ID selector (to embed unrelated screens)

Template.ScreenIdSettingValue.onCreated ->
  @viewId = new ReactiveVar

Template.ScreenIdSettingValue.onRendered ->
  @autorun =>
    if screen = Screens.findOne Template.currentData().value
      @viewId.set screen.view

Template.ScreenIdSettingValue.helpers
  modules: -> Modules.find()
  views: -> Views.find module: @_id
  currentView: ->
    {viewId} = Template.instance()
    viewId.get()
  view: ->
    {viewId} = Template.instance()
    Views.findOne viewId.get()
  screens: ->
    {viewId} = Template.instance()
    Screens.find view: viewId.get()

Template.ScreenIdSettingValue.events
  'change select[name=view]': (event) ->
    {viewId} = Template.instance()
    viewId.set event.target.value
  'blur select[name=view]': (event) ->
    event.stopPropagation() # can't save view as screen
