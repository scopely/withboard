currentView = new ReactiveVar

Template.StatusDisplayCol.helpers
  displayIcon: ->
    if not @token
      icon: 'timelapse', color: '#ffc107'
    else if not @online
      icon: 'signal_wifi_off', color: '#ff5722'
    else if @online and @online is @config?.rebootIf
      icon: 'timelapse', color: '#ba68c8' # shouldn't stay for long
    else if @status?.displayOn is false
      icon: 'nights_stay', color: '#03a9f4'
    else
      icon: 'cloud_done', color: '#8bc34a'

  fromNow: (time) -> if time
    Chronos.liveMoment()
    moment(time).fromNow()

  avgTempOf: (list) ->
    return 'N/A' unless list.length
    avg = list.reduce(((a,b) -> a+b), 0) / list.length
    return "#{Math.round(avg*10)/10}°C"

  memUsedRatio: ->
    ratio = (@capacity - @availableCapacity) / @capacity
    "#{Math.round(ratio*1000)/10}%"

Template.StatusDisplayCol.events
  'click a[href="#reboot"]': (evt) ->
    evt.preventDefault()
    # schedule the display for an immediate reboot
    Displays.update @_id, $set:
      'config.rebootIf': @online
