remotes = {}

# called by dynamic fetcher code
root.hookRemote = (boardId, cb) ->
  remotes[boardId] = cb

# called by hardware appliances
Meteor.methods boardButton: (boardId, buttonId, delta) ->
  console.log 'BOARD', boardId, 'BUTTON', buttonId, 'DELTA', delta
  remotes[boardId]?(buttonId)
