Meteor.smartPublish '/ng/display', (token, pane) ->
  check token, String
  unless display = Displays.findOne {token}
    throw new Meteor.Error 404, 'No such display'

  ipAddress = Meteor.call('getClientIpAddress')
  console.log 'Starting pub for', display._id, pane, token, ipAddress

  # Only primary subs should report status
  unless pane
    val = Math.random().toString(16).slice(2)
    @onStop ->
      Displays.update {_id: display._id, online: val},
        $unset: online: 1
        $set: lastSeen: new Date()
    Displays.update display._id,
      $set:
        online: val
        latestIp: ipAddress
      $unset: lastSeen: 1

  if pane
    @addDependency 'displays', 'panes', (display) ->
      Screens.find display.panes?[pane]?.screen
  else
    @addDependency 'displays', 'screen', (display) ->
      Screens.find display.screen

  @addDependency 'screens', 'view', (screen) ->
    Views.find screen.view
  @addDependency 'screens', '_id', (screen) -> [
    Settings.find context: type: 'screen', id: screen._id
    Data.find context: type: 'screen', id: screen._id
  ]

  @addDependency 'views', 'module', (view) -> [
    Modules.find view.module
    Settings.find context: type: 'module', id: view.module
    Data.find context: type: 'module', id: view.module
  ]

  @addDependency 'settings', 'value', (setting) ->
    switch setting.reference
      when 'screen' then Screens.find setting.value

  [
    Displays.find display._id
    Messages.find {type: 'notification'},
      sort:
        enableAt: -1
      limit: 5
  ]

Meteor.startup ->
  Displays.update {}, {$unset: online: 1}, multi: true
