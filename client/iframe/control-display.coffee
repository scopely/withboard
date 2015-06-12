Template.ControlIframeDisplay.events
  'change #url': (event) ->
    Displays.update @_id, $set:
      'config.iframeUrl': event.target.value

  'change #scale': (event) ->
    Displays.update @_id, $set:
      'config.iframeScale': event.target.value

  'change #refresh': (event) ->
    Displays.update @_id, $set:
      'config.iframeRefresh': event.target.value

Template.ControlIframeDisplay.helpers
  scaleAttrs: ->
    min: 0.5
    max: 2.5
    step: 0.1
    value: @config.iframeScale ? 1

  refreshAttrs: ->
    min: 1
    max: 60
    step: 1
    value: @config.iframeRefresh ? 30
