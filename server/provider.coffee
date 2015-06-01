checkProviderKey = (key) ->
  if realKey = Config.findOne(key: 'provider-key')
    realKey.value is key

Meteor.methods
  setConfig: (auth, key, value) ->
    unless checkProviderKey auth
      throw new Meteor.Error 401, 'Invalid provider key'

    console.log 'Provider set config', key, 'to', JSON.stringify(value).substr(0, 256)
    Config.upsert {key: key},
      key: key
      value: value
      source: 'provider'

  setState: (auth, key, value) ->
    unless checkProviderKey auth
      throw new Meteor.Error 401, 'Invalid provider key'

    console.log 'Provider set state', key, 'to', JSON.stringify(value).substr(0, 256)
    State.upsert {key: key},
      key: key
      value: value
      source: 'provider'

Meteor.publish 'provider', (key) ->
  unless checkProviderKey key
    return @error new Meteor.Error 401, 'Invalid provider key'
  console.log 'Provider connected'

  [
    Displays.find()
    Config.find()
    State.find()
  ]
