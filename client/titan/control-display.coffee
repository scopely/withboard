Template.ControlTitanDisplay.events
  'change [type=text]': (event) ->
    if event.target.value
      Displays.update @_id, $set:
        'config.titanApiKey': event.target.value
    else
      Displays.update @_id, $unset:
        'config.titanApiKey': 1
