Meteor.smartPublish '/module/list', ->
  unless @userId
    throw new Meteor.Error 'not-authorized', 'You must be logged in to do that'

  [
    Modules.find {},
      fields:
        name: 1
    Views.find {},
      fields:
        name: 1
        module: 1
  ]