Meteor.methods
  setPlatform: (_id, platform) ->
    console.log 'platform', _id, platform
    check _id, String
    check platform, String
    if platform in ['chromecast', 'chrome app']
      Displays.update _id, $set: {platform}

  setStatus: (_id, fields) ->
    #console.log 'status', _id, fields
    check _id, String
    throw new Meteor.Error('wat') unless fields.constructor is Object
    throw new Meteor.Error('ugh') unless display = Displays.findOne _id

    status = display.status ? {}
    for key, val of fields
      status[key] = val

    Displays.update _id, $set: {status}
