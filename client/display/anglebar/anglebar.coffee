timeDep = new Tracker.Dependency()
time = moment()

Meteor.setInterval ->
  time = moment()
  timeDep.changed()
, 1000

Template.AngleBar.helpers
  clock: (timeFormat) ->
    timeDep.depend()
    time.format timeFormat

  label: ->
    if display = Displays.findOne()
      {title, role, _id} = display
      Session.get('label') or title or role or _id
    else 'Inactive'
    # Config.findOne(key: 'org').value

  clan: ->
    clan  =  State.findOne key: 'daily-clan'
    clans = Config.findOne key: 'clans'

    if clan and clans
      clans.value.filter((c) ->
        c.key == clan.value
      )[0]

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

  sliderPos: ->
    state = State.findOne key: 'announce'

    if state and state.value.active and state.value.expires
      timeDep.depend()

    active = state and state.value.active
    if active and state.value.expires
      active = moment(state.value.expires).isAfter()

    if active then '-55px' else '-1000px'
