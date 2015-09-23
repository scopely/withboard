window.addEventListener 'message', ({data, origin}) ->
  if url = Config.findOne(key: 'titan-url')
    return unless origin == url.value.split('/').slice(0,3).join('/')
    console.log data

    if data.type is 'context'
      Session.set 'icon url', data.icon
      Session.set 'label', data.name
    else if data.type is 'ready'
      setState origin, url

setState = (origin, url) -> if display = Displays.findOne()
  apiKey = display.config.titanApiKey
  dashboardId = display.config.titanDashboardId
  origin = url.value.split('/').slice(0,3).join('/')

  iframe = document.getElementById('titan')
  iframe.contentWindow.postMessage {view: 'dashboard', apiKey, dashboardId}, origin

Template.DisplayTitan.onDestroyed ->
  Session.set 'icon url'
  Session.set 'label'
