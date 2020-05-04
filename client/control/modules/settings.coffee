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

        Settings.insert {context, @key, value}, (err) -> if err
          alert "Problem saving setting\n\n#{err.name} #{err.message}"
        else
          console.log 'setting create ok to', value


#####################################################
# User ID selector (to inherit Google credentials)

Template.UserIdSettingValue.helpers
  # Provide list of users which have Google Drive granted
  users: ->
    Meteor.users.find({
      'services.google.scope': 'https://www.googleapis.com/auth/drive.readonly'
    })

Template.UserIdSettingValue.onRendered ->
  # Force state to reflect data store
  @autorun =>
    if userId = Template.currentData().value
      @$('select').val userId
