Router.map ->
  @route 'displays',
    path: '/control'
    template: 'Displays'
    layoutTemplate: 'ControlLayout'
    data: ->
      displays: Displays.find {}, sort: name: 1

  @route 'pair',
    path: '/control/pair/:code'
    action: ->
      Displays.update @params.code, $set:
        pairedAt: new Date()
        token: Random.secret()
      , -> Router.go 'displays'

  @route 'settings',
    path: '/control/settings'
    template: 'Configs'
    layoutTemplate: 'ControlLayout'
    data: ->
      configs: Config.find {}, sort: key: 1

  @route 'states',
    path: '/control/states'
    template: 'States'
    layoutTemplate: 'ControlLayout'
    data: ->
      states: State.find {}, sort: key: 1

  @route 'index',
    path: '/',
    action: ->
      @redirect '/control'
