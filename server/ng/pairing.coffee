getNewCode = ->
  ipAddress = Meteor.call('getClientIpAddress')
  x = 5
  while x--
    try return Displays.insert
      _id: Math.random().toString(36).slice(2, 6)
      firstSeen: new Date()
      firstIp: ipAddress
      latestIp: ipAddress
      ng: true
    catch ex
      throw ex unless ex.code is 11000

Meteor.publish '/ng/pair', ->
  code = getNewCode()

  @onStop ->
    display = Displays.findOne code
    if display and not display.token
      Displays.remove code

  Displays.find code,
    fields: token: 1

Meteor.startup ->
  Displays.remove token: null
