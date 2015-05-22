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
    else if Session.get 'label'
      Session.get 'label'
    else if user.profile.type != 'display' and user.profile.name
      user.profile.name.split(' ')[0]
    else if user.profile.title or user.profile.role
      user.profile.title or user.profile.role
    else if user.username
      user.username.slice 8
    else
      Config.findOne(key: 'org').value

  clan: ->
    clan  =  State.findOne key: 'daily-clan'
    clans = Config.findOne key: 'clans'

    if clan and clans
      clans.value.filter((c) ->
        c.key == clan.value
      )[0]
    else {}

  announce: ->
    state = State.findOne key: 'announce'
    if state then state.value

  music: ->
    state = State.findOne key: 'now-playing'
    if state and state.value then state.value[0]

  trimmed: (string) ->
    if string.length < 23
      string
    else
      string.substr(0, 20) + '...'

  @autorun =>
    state = State.findOne key: 'announce'

    if state and state.value.active and state.value.expires
      timeDep.depend()

    active = state and state.value.active
    if active and state.value.expires
      active = moment(state.value.expires).isAfter()

    @find('.sliding').style.left = if active
      (@find('.primary').clientWidth + 50) + 'px'
    else
      '-1000px'
