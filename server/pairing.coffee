pairingSubs = {}

Meteor.methods
  getPairingCode: ->
    code = false
    while not code or pairingSubs[code] != undefined
      code = Math.random().toString(36).slice(2, 6)

    console.log 'New pairing code:', code
    pairingSubs[code] = false
    code

  confirmPairing: (code) ->
    check code, String
    console.log code, 'wants to finish pairing'

    if pairingSubs[code] is undefined
      throw new Meteor.Error 400, 'Unknown or expired pairing session'
    if pairingSubs[code] is false
      throw new Meteor.Error 400, 'Display is not ready to pair'
    if not pairingSubs[code].adminId
      throw new Meteor.Error 401, 'Pairing has not been authorized yet'

    id = Meteor.users.insert
      username: "display-#{code}"
      profile:
        type: 'display'
        ownerId: pairingSubs[code].adminId

    console.log 'Display user', id, 'created from', code

    if pairingSubs[code].returnTo
      pairingSubs[code].returnTo.ready()
      pairingSubs[code].returnTo.stop()
      delete pairingSubs[code].returnTo
    pairingSubs[code].stop()

    token = Accounts._generateStampedLoginToken()
    Accounts._insertLoginToken id, token

    conn = @.connection
    Meteor._noYieldsAllowed ->
      Accounts._setLoginToken id, conn, Accounts._hashLoginToken(token.token)

    this.setUserId id

    id: id
    token: token.token

Meteor.publish 'pairing', (code) ->
  check code, String
  console.log 'Got pairing subscription from', code

  if pairingSubs[code] is undefined
    return @error new Meteor.Error 400, 'Unknown or expired pairing code'
  pairingSubs[code] = @

  @onStop ->
    console.log code, 'stopped caring about pairing'
    delete pairingSubs[code]

Meteor.publish 'pair', (code) ->
  check code, String
  console.log @userId or 'User', 'wants to pair to', code

  if pairingSubs[code] is undefined
    @error new Meteor.Error 400, 'Unknown or expired pairing code'
  else if pairingSubs[code] is false
    @error new Meteor.Error 400, 'Display is not ready to pair'
  else
    sub = pairingSubs[code]
    sub.ready()
    pairingSubs[code].adminId = @userId
    pairingSubs[code].returnTo = @
  return
