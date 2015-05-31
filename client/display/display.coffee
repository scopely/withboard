Session.set 'display token', localStorage.DisplayToken

sub = null
Template.Display.rendered = ->
  @autorun ->
    sub = if token = Session.get 'display token'
      localStorage.DisplayToken = token
      @subscribe ['display', token, onStop: (err) ->
        console.log err
        Session.set 'display token'
      ]
    else
      delete localStorage.DisplayToken
      @subscribe ['pair']

  @autorun ->
    if display = Displays.findOne()
      if display.token
        Session.set 'display token', display.token
        Router.go "/display/#{display.role ? 'default'}"
      else
        Router.go 'displayPairing'
    else if sub.ready()
      Session.set 'display token', true
      #Router.go 'displayPairing'
    console.log 'display', display, sub.ready()

  # Support chromecast receivers
  if window.cast and cast.receiver
    window.castReceiverManager = cast.receiver.CastReceiverManager.getInstance()
    window.castReceiverManager.start()
