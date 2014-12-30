session = null

initializeCastApi = ->
  applicationID = '8ED67160'
  sessionRequest = new chrome.cast.SessionRequest applicationID
  apiConfig = new chrome.cast.ApiConfig sessionRequest, sessionListener, receiverListener

  chrome.cast.initialize apiConfig, ->
    console.log 'cast: init success'
  , ->
    console.log 'cast: error'

onSuccess = (message) ->
  console.log 'cast:', message

onStopAppSuccess = ->
  console.log 'cast: session stopped'

sessionListener = (e) ->
  console.log 'cast: new session ID:', e.sessionId
  session = e

  if session.media.length != 0
    console.log 'cast: found', session.media.length, 'existing media sessions.'
  session.addUpdateListener sessionUpdateListener.bind @

sessionUpdateListener = (isAlive) ->
  message = if isAlive then 'session updated:' else 'session removed:'
  console.log 'cast:', message, session.sessionId

  session = null unless isAlive

receiverListener = (e) ->
  if e is 'available'
    console.log 'cast: receiver found'
  else
    console.log 'cast: receiver list empty'

launchApp = () ->
  console.log 'cast: launching app...'
  chrome.cast.requestSession onRequestSessionSuccess, ->
    console.log 'cast: launch error'

onRequestSessionSuccess = (e) ->
  console.log 'cast: session success:', e.sessionId
  session = e
  session.addUpdateListener sessionUpdateListener.bind @
  if session.media.length != 0
    onMediaDiscovered 'onRequestSession', session.media[0]

  session.addMediaListener onMediaDiscovered.bind @, 'addMediaListener'
  session.addUpdateListener sessionUpdateListener.bind @

stopApp = () ->
  session.stop onStopAppSuccess, onError


Template.ControlLayout.rendered = ->
  Meteor.subscribe 'displays'
  Meteor.subscribe 'config'
  Meteor.subscribe 'state'

  console.log 'Setting up Cast sender'
  timer = setInterval ->
    if chrome.cast and chrome.cast.isAvailable
      console.log 'Setting up Cast'
      clearInterval timer
      initializeCastApi()
  , 50
