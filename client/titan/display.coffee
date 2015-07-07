Template.DisplayTitan.onRendered ->
  setTimeout (=> @autorun ->
    if (display = Displays.findOne()) and url = Config.findOne(key: 'titan-url')
        apiKey = display.config.titanApiKey
        dashboardId = display.config.titanDashboardId
        origin = url.value.split('/').slice(0,3).join('/')

        iframe = document.getElementById('titan')
        iframe.contentWindow.postMessage {view: 'dashboard', apiKey, dashboardId}, origin
  ), 5000
