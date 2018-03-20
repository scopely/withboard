session = null
debug = false

initializeCastApi = ->
  sessionRequest = new chrome.cast.SessionRequest Meteor.settings.public.cast_application_id
  apiConfig = new chrome.cast.ApiConfig sessionRequest, sessionListener, receiverListener

  chrome.cast.initialize apiConfig, ->
    console.log 'cast: init success' if debug
  , ->
    console.log 'cast: error'

onSuccess = (message) ->
  console.log 'cast:', message if debug

onStopAppSuccess = ->
  console.log 'cast: session stopped' if debug

sessionListener = (e) ->
  console.log 'cast: new session ID:', e.sessionId if debug
  session = e

  if session.media.length isnt 0
    console.log 'cast: found', session.media.length, 'existing media sessions.' if debug
  session.addUpdateListener sessionUpdateListener.bind @

sessionUpdateListener = (isAlive) ->
  message = if isAlive then 'session updated:' else 'session removed:'
  console.log 'cast:', message, session.sessionId if debug

  session = null unless isAlive

receiverListener = (e) ->
  if e is 'available'
    console.log 'cast: receiver found' if debug
  else
    console.log 'cast: receiver list empty' if debug

launchApp = ->
  console.log 'cast: launching app...'
  chrome.cast.requestSession onRequestSessionSuccess, ->
    console.log 'cast: launch error'

onRequestSessionSuccess = (e) ->
  console.log 'cast: session success:', e.sessionId if debug
  session = e
  session.addUpdateListener sessionUpdateListener.bind @
  if session.media.length isnt 0
    onMediaDiscovered 'onRequestSession', session.media[0]

  session.addMediaListener onMediaDiscovered.bind @, 'addMediaListener'
  session.addUpdateListener sessionUpdateListener.bind @

stopApp = ->
  session.stop onStopAppSuccess, onError


initTimer = null
startTimer = -> if chrome? and not initTimer
  console.log 'Setting up Cast sender' if debug
  initTimer = setInterval ->
    if chrome.cast?.isAvailable
      console.log 'Setting up Cast' if debug
      clearInterval initTimer
      initializeCastApi()
  , 150

Template.Login.onRendered ->
  startTimer()
Template.ControlLayout.onRendered ->
  startTimer()
