assertProvider = (userId) ->
  if not userId
    console.log 'Provider attempt with no user id'
    throw new Meteor.Error 401, 'Not enough privledges'

  if not Meteor.users.findOne(userId).provider
    console.log 'Provider attempt from non-provider'
    throw new Meteor.Error 401, 'Not provider'

Meteor.methods
  setupProvider: (key) ->
    realKey = Config.findOne key: 'provider-key'
    if not realKey or realKey.value != key
      throw new Meteor.Error 401, 'Invalid provider key'
    else
      console.log 'Provider connected'

    user = Meteor.users.findOne provider: true
    this.setUserId if user
      user._id
    else
      Meteor.users.insert
        provider: true
        profile: {}
    true

  setConfig: (key, value) ->
    assertProvider @userId

    console.log 'Provider set config', key, 'to', JSON.stringify(value).substr(0, 256)
    Config.upsert {key: key},
      key: key
      value: value
      source: 'provider'

  setState: (key, value) ->
    assertProvider @userId

    console.log 'Provider set state', key, 'to', JSON.stringify(value).substr(0, 256)
    State.upsert {key: key},
      key: key
      value: value
      source: 'provider'

Meteor.publish 'provider', (key) ->
  realKey = Config.findOne key: 'provider-key'
  if not realKey or realKey.value != key
    return @error new Meteor.Error 401, 'Invalid provider key'

  [
    Displays.find()
    Config.find()
    State.find()
  ]
