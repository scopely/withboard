Template.ControlImageDisplay.events
  'change #url': (event) ->
    Displays.update @_id, $set:
      'config.imageUrl': event.target.value

  'change #fullScreen': (event) ->
    Displays.update @_id, $set:
      'config.fullScreen': event.target.checked
