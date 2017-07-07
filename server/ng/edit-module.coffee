Meteor.smartPublish '/module/edit', (moduleId) ->
  unless @userId
    throw new Meteor.Error 'not-authorized', 'You must be logged in to do that'

  check moduleId, String
  unless module = Modules.findOne moduleId
    throw new Meteor.Error 404, 'No such module'

  [
    Modules.find module._id
    Settings.find context: type: 'module', id: module._id
    Views.find module: module._id
  ]