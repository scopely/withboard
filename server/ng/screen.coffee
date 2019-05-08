Meteor.smartPublish '/screens/get', (id, token) ->
  unless @userId
    throw new Meteor.Error 'not-authorized', 'You must be logged in to do that'

  check id, String
  unless screen = Screens.findOne id
    throw new Meteor.Error 404, 'No such screen'

  @addDependency 'screens', 'view', (screen) ->
    Views.find screen.view

  @addDependency 'screens', '_id', (screen) -> [
    Settings.find context: type: 'screen', id: screen._id
    Data.find context: type: 'screen', id: screen._id
  ]

  @addDependency 'views', 'module', (view) -> [
    Settings.find context: type: 'module', id: view.module
    Data.find context: type: 'module', id: view.module
  ]

  Screens.find screen._id
