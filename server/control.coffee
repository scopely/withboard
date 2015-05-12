Meteor.publish 'displays', ->
  if @userId and Meteor.users.findOne(@userId).profile.type != 'display'
    Meteor.users.find
      'profile.type': 'display'
    , fields:
      profile: 1
      username: 1
  else if @userId
    Meter.user()
  else
    []

Meteor.methods
  updateDisplay: (_id, fields) ->
    user = Meteor.users.findOne @userId
    return null if not user or user.profile.type == 'display'
    console.log 'DISPLAY UPDATE:', _id, fields

    display = Meteor.users.findOne _id
    return false unless display and display.profile

    obj = {};
    Object.keys(fields).forEach (key) ->
      obj["profile.#{key}"] = fields[key]

    Meteor.users.update _id, $set: obj

  deleteDisplay: (_id) ->
    user = Meteor.users.findOne @userId
    return null if not user or user.profile.type == 'display'
    console.log 'DISPLAY DELETE:', _id, fields
    Meteor.users.remove _id

isAdmin = (userId, doc) ->
  if userId
    user = Meteor.users.findOne userId
    not user.provider and user.profile and user.profile.type != 'display'
  else
    false

Meteor.startup ->
  Config.allow insert: isAdmin, update: isAdmin, remove: isAdmin
  State.allow  insert: isAdmin, update: isAdmin, remove: isAdmin
