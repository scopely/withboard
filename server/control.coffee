Meteor.publish 'control', -> [
  Displays.find()
  Config.find()
  State.find()
] if @userId

isAdmin = (userId, doc) -> !!userId
opts =
  insert: isAdmin
  update: isAdmin
  remove: isAdmin

Meteor.startup ->
  Config.allow opts
  State.allow opts
  Displays.allow opts
