Template.ControlImagesDisplay.events
  'change .url': (event) ->
    Displays.update @_id, $set:
      'config.imageSet': event.target.value

  'change .fullScreen': (event) ->
    Displays.update @_id, $set:
      'config.fullScreen': event.target.checked

  'change #interval': (event) ->
    Displays.update @_id, $set:
      'config.imageInterval': event.target.value

Template.ControlImagesDisplay.helpers
  intervalAttrs: ->
    min: 5
    max: 120
    step: 5
    value: @config.imageInterval ? 30
