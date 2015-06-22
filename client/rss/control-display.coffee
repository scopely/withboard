Template.ControlRssDisplay.events
  'change #feed': (event) ->
    Displays.update @_id, $set:
      'config.rss': event.target.value

  'change #interval': (event) ->
    Displays.update @_id, $set:
      'config.rssInterval': event.target.value

Template.ControlRssDisplay.helpers
  intervalAttrs: ->
    min: 5
    max: 120
    step: 5
    value: @config.rssInterval ? 30
