serverInstance = Random.id()

Meteor.smartPublish '/sharing/access', (_id, token) ->
  check _id, String
  unless share = Shares.findOne {_id}
    throw new Meteor.Error 404, 'No content at this URL.'

  # Security checks
  switch share.sharing
    when 'myself'
      unless @userId
        throw new Meteor.Error 'not-logged-in', 'You must be logged in to view this content.'
      unless @userId is share.owner
        throw new Meteor.Error 'not-authorized', 'This sharing link is private. Sorry about that.'

    when 'domain'
      unless @userId
        throw new Meteor.Error 'not-logged-in', 'You must be logged in to view this content.'

    when 'public'
      check token, String
      unless token is share.token
        throw new Meteor.Error 'invalid-token', 'The link you are using has expired.'

    else
      throw new Meteor.Error 'invalid-sharing', 'The content you are trying to view is misconfigured.'


  @addDependency 'shares', 'owner', (share) ->
    Meteor.users.find share.owner

  @addDependency 'shares', 'entries', (share) ->
    Screens.find
      _id: $in: share.entries.map (e) -> e.id

  @addDependency 'screens', 'view', (screen) ->
    Views.find screen.view

  @addDependency 'screens', '_id', (screen) -> [
    Settings.find context: type: 'screen', id: screen._id
    Data.find context: type: 'screen', id: screen._id
  ]

  # Record this viewing session
  logId = ShareLog.insert
    share     : share._id
    viewer    : @userId
    server    : serverInstance
    ipAddress : Meteor.call 'getClientIpAddress'
    screenSet : []
    startedAt : new Date
  @onStop ->
    ShareLog.update logId, $set:
      endedAt: new Date

  [
    Shares.find {_id},
      fields:
        owner: 1
        title: 1
        entries: 1
  ,
    ShareLog.find
      _id: logId
  ]

Meteor.startup ->
  # let viewers add info to their session
  ShareLog.allow
    update: (userId, doc) ->
      doc.viewer is userId

  # finish out old sessions in case the previous server failed
  ShareLog.update
    server:
      $ne: serverInstance
    endedAt:
      $exists: false
  ,
    $set:
      endedAt: new Date
  ,
    multi: true
