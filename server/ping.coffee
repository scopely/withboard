Meteor.methods
  ping: (obj = {}) ->
    obj.serverMillis = +new Date
    return obj