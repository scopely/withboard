Router.map ->
  @route 'displays',
    path: '/assign'
    template: 'Displays'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      displays: Displays.find {}, sort: name: 1

  @route 'ManageDisplay',
    path: '/control/display/:code'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      Displays.findOne {
        _id: @params.code.toLowerCase()
      }

  @route 'displaySwap',
    path: '/assign/swap/:code'
    template: 'DisplaySwap'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      code: @params.code

  @route 'pair',
    path: '/pair/:code'
    action: ->
      Displays.update @params.code, $set:
        pairedAt: new Date()
        token: Random.secret()
      , -> Router.go 'displays'

  @route 'moduleList',
    path: '/modules'
    template: 'ModuleList'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      modules: Modules.find {}, sort: name: 1

  @route 'editModule',
    path: '/modules/:id'
    template: 'EditModule'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      module: Modules.findOne @params.id
      views: Views.find module: @params.id

  @route 'editView',
    path: '/modules/:module/views/:id'
    template: 'EditView'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      module: Modules.findOne @params.module
      view: Views.findOne _id: @params.id, module: @params.module
      screens: Screens.find view: @params.id


  @route 'Messages',
    path: '/messages'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe '/messages/history'
    data: ->
      messages: Messages.find {}, sort: createdAt: -1


  @route 'SharingList',
    path: '/sharing'
    layoutTemplate: 'ControlLayout'
    waitOn: -> [
      Meteor.subscribe 'control'
      Meteor.subscribe '/sharing/list'
    ]
    data: ->
      myShares: Shares.find(owner: Meteor.userId())
      otherShares: Shares.find(owner: $ne: Meteor.userId())

  @route 'ManageSharing',
    path: '/sharing/:id'
    layoutTemplate: 'ControlLayout'
    waitOn: -> [
      Meteor.subscribe 'control'
      Meteor.subscribe '/sharing/manage', @params.id
    ]
    data: ->
      Shares.findOne @params.id


  @route 'StatusMain',
    path: '/status'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      views: Views.find {ttl: $ne: null}, sort: module: 1, name: 1
      displays: Displays.find {token: $ne: null}, sort: name: 1
      unpaired: Displays.find {token: null}

  @route 'StatusDevices',
    path: '/status/devices'
    layoutTemplate: 'ControlLayout'
    waitOn: ->
      Meteor.subscribe 'control'
    data: ->
      deviceFocused: true
      displays: Displays.find {token: $ne: null}, sort: name: 1
      unpaired: Displays.find {token: null}


  @route 'index',
    path: '/'
    action: ->
      @redirect '/assign'

  @route 'reroute',
    path: '/control'
    action: ->
      @redirect '/assign'
