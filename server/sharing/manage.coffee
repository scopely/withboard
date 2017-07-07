Meteor.publish '/sharing/list', ->
  Shares.find {},
    fields:
      owner: 1
      title: 1
      sharing: 1

Meteor.publish '/sharing/manage', (_id) -> [
  Shares.find {_id}
 
  # to support adding content
  Modules.find {}, fields: name: 1
  Views.find {}, fields: name: 1, module: 1
  Screens.find {}, fields: name: 1, view: 1
]