remotes = {}

root.hookRemote = (boardId, cb) ->
  remotes[boardId] = cb

Meteor.methods boardButton: (boardId, buttonId, delta) ->
  console.log 'BOARD', boardId, 'BUTTON', buttonId, 'DELTA', delta
  remotes[boardId]?(buttonId)