Router.map ->
  @route 'control',
    path: '/control'
    template: 'ControlHome'
    layoutTemplate: 'ControlLayout'

  @route 'displays',
    path: '/control/displays'
    template: 'Displays'
    layoutTemplate: 'ControlLayout'
    data: ->
      displays: Meteor.users.find 'profile.type': 'display'
      users: Meteor.users.find 'profile.type': {$ne: 'display'}

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
