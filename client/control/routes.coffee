Router.map ->
  @route 'displays',
    path: '/control'
    template: 'Displays'
    layoutTemplate: 'ControlLayout'
    data: ->
      displays: Meteor.users.find {'profile.type': 'display'}, sort: 'profile.name': 1
      users: Meteor.users.find 'profile.type': {$ne: 'display'}

  @route 'pair',
    path: '/control/pair/:code'
    waitOn: -> Meteor.subscribe 'pair', @params.code
    data: -> Router.go 'displays' if Meteor.user()

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
