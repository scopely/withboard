Router.route '/s/:id',
  template: 'Share'
  waitOn: ->
    Meteor.subscribe '/sharing/access', @params.id, @params.query.token
  data: ->
    if share = Shares.findOne @params.id
      share: share
      screens: share.entries.map (e) -> Screens.findOne(e.id)
      owner: Meteor.users.findOne share.owner

Router.route '/share/:screen',
  template: 'OldSharingLink'
