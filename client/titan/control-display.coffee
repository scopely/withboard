Template.ControlTitanDisplay.events
  'change #app': (event) ->
    if event.target.value
      Displays.update @_id, $set:
        'config.titanApiKey': event.target.value
    else
      Displays.update @_id, $unset:
        'config.titanApiKey': 1

  'change #dashboard': (event) ->
    if event.target.value
      Displays.update @_id, $set:
        'config.titanDashboardId': event.target.value
    else
      Displays.update @_id, $unset:
        'config.titanDashboardId': 1

  'change #dashColumns': (event) ->
    Displays.update @_id, $set:
      'config.titanDashColumns': event.target.value

Template.ControlTitanDisplay.helpers
  dashColumnsAttrs: ->
    min: 1
    max: 4
    step: 1
    value: @config.titanDashColumns ? 2
