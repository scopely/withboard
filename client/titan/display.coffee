window.addEventListener 'message', ({data, origin}) ->
  if (display = Displays.findOne()) and url = Config.findOne(key: 'titan-url')
    return unless origin == url.value.split('/').slice(0,3).join('/')
    console.log data
    return unless data.type is 'context'
    Session.set 'icon url', data.icon
    Session.set 'label', data.name

Template.DisplayTitan.onRendered ->
  setTimeout (=> @autorun ->
    if (display = Displays.findOne()) and url = Config.findOne(key: 'titan-url')
      apiKey = display.config.titanApiKey
      dashboardId = display.config.titanDashboardId
      origin = url.value.split('/').slice(0,3).join('/')

      iframe = document.getElementById('titan')
      iframe.contentWindow.postMessage {view: 'dashboard', apiKey, dashboardId}, origin
  ), 15000

Template.DisplayTitan.onDestroyed ->
  Session.set 'icon url'
  Session.set 'label'
