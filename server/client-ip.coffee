Meteor.methods
  getClientIpAddress: ->
    @connection.httpHeaders['x-forwarded-for']?.split(',')[0] ? @connection.clientAddress
