Template.ControlIframeDisplay.events
  'change #url': (event) ->
    Displays.update @_id, $set:
      'config.iframeUrl': event.target.value

  'change #scale': (event) ->
    Displays.update @_id, $set:
      'config.iframeScale': event.target.value
