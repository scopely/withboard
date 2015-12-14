originOf = (url) -> url.split('/').slice(0, 3).join('/')

window.addEventListener 'message', ({data, origin}) ->
  if url = Config.findOne(key: 'titan-url')?.value
    return unless origin == originOf(url)

    if data.type is 'context'
      Session.set 'icon url', data.icon
      Session.set 'label', data.name
    else if data.type is 'ready'
      setState origin, url

setState = (origin, url) -> if display = Displays.findOne()
  apiKey = display.config.titanApiKey
  dashboardId = display.config.titanDashboardId
  dashColumns = display.config.titanDashColumns

  iframe = document.getElementById('titan')
  iframe.contentWindow.postMessage {
    view: 'dashboard'
    apiKey, dashboardId, dashColumns
  }, originOf(url)

Template.DisplayTitan.onDestroyed ->
  Session.set 'icon url'
  Session.set 'label'

Template.DisplayTitan.onRendered ->
  @autorun -> if url = Config.findOne(key: 'titan-url')?.value
    setState originOf(url), url
