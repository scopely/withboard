timeDep = new Tracker.Dependency()
time = moment()

Meteor.setInterval ->
  time = moment()
  timeDep.changed()
, 1000

Template.Display.helpers
  clock: (timeFormat) ->
    timeDep.depend()
    time.format timeFormat

  label: () ->
    user = Meteor.user()

    if !user
      'Inactive'
    else if user.profile.type != 'display' and user.profile.name
      user.profile.name.split(' ')[0]
    else if user.profile.title or user.profile.role
      user.profile.title or user.profile.role
    else if user.username
      user.username.slice 8
    else
      Config.findOne(key: 'org').value

  clan: () ->
    clan  =  State.findOne key: 'daily-clan'
    clans = Config.findOne key: 'clans'

    if clan and clans
      clans.value.filter((c) ->
        c.key == clan.value
      )[0]
    else {}

  announce: ->
    state = State.findOne key: 'announce'
    if state then state.value else null

  music: ->
    state = State.findOne key: 'now-playing'
    if state and state.value then state.value[0] else null

  trimmed: (string) ->
    if string.length < 25
      string
    else
      string.substr(0, 22) + '...'

Template.Display.rendered = ->
  Meteor.subscribe 'state'
  Meteor.subscribe 'config'

  @autorun ->
    user = Meteor.user()

    if not Meteor.userId()
      Router.go 'displayPairing'
    else if user and user.profile.role
      slash = if user.profile.role == 'default' then '' else '/'
      Router.go '/display' + slash + user.profile.role

  self = @
  @autorun ->
    state = State.findOne key: 'announce'

    if state and state.value.active and state.value.expires
      timeDep.depend()

    active = state and state.value.active
    if active && state.value.expires
      active = moment(state.value.expires).isAfter()

    self.find('.sliding').style.left = if active
      (self.find('.primary').clientWidth + 50) + 'px'
    else
      '-1000px'

  # Support chromecast receivers
  if window.cast and cast.receiver
    window.castReceiverManager = cast.receiver.CastReceiverManager.getInstance()
    window.castReceiverManager.start()
