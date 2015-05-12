Meteor.publish 'display', ->
  return [] unless @userId

  val = Math.random().toString(16).slice(2)
  @onStop =>
    Meteor.users.update {_id: @userId, online: val}, $set: online: false
  Meteor.users.update @userId, $set: online: val

  [Config.find(), State.find()]
