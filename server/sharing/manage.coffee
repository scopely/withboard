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

Meteor.smartPublish '/sharing/manage', (_id) ->
  unless @userId
    throw Meteor.Error 'logged-out'

  @addDependency 'shareLog', 'viewer', (log) ->
    Meteor.users.find log.viewer,
      fields:
        profile: 1
        'services.google.email': 1

  [
    Shares.find {_id}
    ShareLog.find {share: _id},
      sort: startedAt: -1
      limit: 25

    # to support adding content
    Modules.find {}, fields: name: 1
    Views.find {}, fields: name: 1, module: 1
    Screens.find {}, fields: name: 1, view: 1
  ]
