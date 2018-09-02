Template.StatusMain.helpers
  firstFailure: ->
    Screens.findOne
      view: @_id
      failure: $ne: null
    , sort: 'failure.since': 1
    ?.failure

  viewIcon: ->
    bools = Screens.find
      view: @_id
    .map (x) -> !x.failure
    if bools.includes true
      if bools.includes false
        icon: 'warning', color: '#ffc107'
      else
        icon: 'cloud_done', color: '#8bc34a'
    else
      if bools.includes false
        icon: 'error', color: '#ff5722'
      else
        icon: 'tv_off', color: '#78909c'

  displayIcon: ->
    if not @token
      icon: 'timelapse', color: '#ffc107'
    else if @online
      icon: 'cloud_done', color: '#8bc34a'
    else
      icon: 'signal_wifi_off', color: '#ff5722'

  fromNow: (time) -> if time
    moment(time).fromNow()

  viewModule: ->
    Modules.findOne @module
