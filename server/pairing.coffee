getNewCode = ->
  x = 5
  while x--
    try
      code = Math.random().toString(36).slice(2, 6)
      return Displays.insert _id: code, firstSeen: new Date()
    catch ex
      throw ex unless ex.code is 11000

Meteor.publish 'pair', ->
  code = getNewCode()

  @onStop ->
    display = Displays.findOne code
    if display and not display.token
      Displays.remove code

  Displays.find code,
    fields: token: 1
