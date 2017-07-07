Meteor.publish 'control', -> if @userId then [
  Displays.find()
  Meteor.users.find()

  # These are used by the display assignment UI
  Modules.find {}#, fields: name: 1
  Views.find {}#, fields: name: 1, module: 1, settings: 1
  Screens.find {}#, fields: name: 1, view: 1
  Settings.find {}
  # Data.find {}
] else throw Meteor.Error 'logged-out'

isAdmin = (userId, doc) -> !!userId
opts =
  insert: isAdmin
  update: isAdmin
  remove: isAdmin

Meteor.startup ->
  Displays.allow opts

  # TODO: admin only this
  Modules.allow opts
  Views.allow opts

  Screens.allow opts
  Settings.allow opts
  
  Messages.allow opts
  Shares.allow opts
