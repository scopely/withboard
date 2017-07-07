Meteor.methods
  updateScript: (viewId, newScript) ->
    unless @userId
      throw new Meteor.Error 'not-authorized', 'You must be logged in to do that'
      
    Views.update
      _id: viewId
      'template.scripts.key': newScript.key
    , $set:
      'template.scripts.$': newScript
