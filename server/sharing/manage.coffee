Meteor.publish '/sharing/list', -> if @userId then [
  Shares.find {
    # list personal shares and shared shares
    $or: [
      { owner: @userId }
      { sharing: $in: ['public', 'domain'] }
    ]
  },
    fields:
      owner: 1
      title: 1
      sharing: 1
] else throw Meteor.Error 'logged-out'

Meteor.publish '/sharing/manage', (_id) -> if @userId then [
  Shares.find {_id}
 
  # to support adding content
  Modules.find {}, fields: name: 1
  Views.find {}, fields: name: 1, module: 1
  Screens.find {}, fields: name: 1, view: 1
] else throw Meteor.Error 'logged-out'
