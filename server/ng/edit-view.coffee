Meteor.smartPublish '/view/edit', (viewId) ->
  unless @userId
    throw new Meteor.Error 'not-authorized', 'You must be logged in to do that'

  check viewId, String
  unless view = Views.findOne viewId
    throw new Meteor.Error 404, 'No such view'

  @addDependency 'screens', '_id', (s) -> [
    Settings.find context: type: 'screen', id: s._id
  ]

  # TODO: does the editor even want the module?
  @addDependency 'views', 'module', (v) -> [
    Modules.find v.module
    Settings.find context: type: 'module', id: v.module
  ]

  [
    Views.find view._id
    Screens.find view: view._id
  ]