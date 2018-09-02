currentView = new ReactiveVar

Template.StatusMain.helpers
  firstFailure: ->
    Screens.findOne
      view: @_id
      failure: $ne: null
    , sort: 'failure.since': 1
    ?.failure

  viewScreens: ->
    Screens.find
      view: @_id
    , sort: 'name': 1

  viewIcon: ->
    bools = Screens.find
      view: @_id
    .map (x) -> !x.failure
    if @ttl is 0
      icon: 'timer_off', color: '#78909c', title: 'Fetcher is turned off'
    else if bools.includes true
      if bools.includes false
        icon: 'warning', color: '#ffc107', title: 'Some screens are broken'
      else
        icon: 'cloud_done', color: '#8bc34a', title: 'All screens are healthy :)'
    else
      if bools.includes false
        icon: 'error', color: '#ff5722', title: 'Every screen is broken :('
      else
        icon: 'tv_off', color: '#78909c', title: 'No configured screens'

  screenIcon: ->
    if @failure
      icon: 'error', color: '#ffc107'
    else
      icon: 'check', color: '#8bc34a'

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

  interval: ->
    round = (x) -> Math.round(x * 10) / 10
    return "#{@ttl}s" if @ttl <= 60
    minutes = @ttl / 60
    return "#{round minutes}m" if minutes <= 60
    hours = minutes / 60
    return "#{round hours}hr" if hours <= 60
    days = hours / 24
    return "#{round days}d"

  viewCollapser: ->
    if currentView.get() is @_id
      'expand_less'
    else 'expand_more'
  viewIsExpanded: ->
    currentView.get() is @_id

Template.StatusMain.events
  'click a[href="#toggle"]': (evt) ->
    evt.preventDefault()
    if currentView.get() is @_id
      currentView.set null
    else
      currentView.set @_id
