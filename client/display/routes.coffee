Router.map ->
  @route 'displayDefault',
    path: '/display'
    template: 'DisplayDefault'
    layoutTemplate: 'Display'

  @route 'displayDefaultttt',
    path: '/displaydefault'
    template: 'DisplayDefault'
    layoutTemplate: 'Display'

  @route 'displayPairing',
    path: '/display/pairing'
    template: 'DisplayPairing'
    layoutTemplate: 'Display'

  @route 'displayRooms',
    path: '/display/rooms'
    template: 'DisplayRooms'
    layoutTemplate: 'Display'
    data: ->
      cals: State.findOne
        key: 'calendars'

  @route 'displayRecruiting',
    path: '/display/recruiting'
    template: 'DisplayRecruiting'
    layoutTemplate: 'Display'
    data: ->
      State.findOne
        key: 'recruiting-list'

  @route 'displayNewrelic',
    path: '/display/newrelic'
    template: 'DisplayNewrelic'
    layoutTemplate: 'Display'
    data: ->
      State.findOne
        key: 'newrelic'

  @route 'displayMetrics',
    path: '/display/metrics'
    template: 'DisplayMetrics'
    layoutTemplate: 'Display'
    data: ->
      Config.findOne
        key: 'metric-layout'

  @route 'displayTitan',
    path: '/display/titan'
    template: 'DisplayTitan'
    layoutTemplate: 'Display'
    data: ->
      url: Config.findOne key: 'titan-url'

  @route 'displayRoles',
    path: '/display/:role'
    template: 'DisplayDefault'
    layoutTemplate: 'Display'
