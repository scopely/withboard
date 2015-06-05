Meteor.publish 'display', (token) ->
  check token, String
  unless display = Displays.findOne {token}
    return @error new Meteor.Error 404, 'No such display'

  val = Math.random().toString(16).slice(2)
  @onStop ->
    Displays.update {_id: display._id, online: val},
      $unset: online: 1
  Displays.update display._id,
    $set: online: val

  [
    Displays.find display._id
    Config.find()
    State.find()
  ]

Meteor.startup ->
  Displays.update {}, {$unset: online: 1}, multi: true
