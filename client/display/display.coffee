Template.Display.rendered = ->
  @subscribe 'display'

  @autorun ->
    user = Meteor.user()

    if not Meteor.userId()
      Router.go 'displayPairing'
    else if user and user.profile.role
      Router.go '/display' +
        if user.profile.role == 'default' then '' else "/#{user.profile.role}"

  # Support chromecast receivers
  if window.cast and cast.receiver
    window.castReceiverManager = cast.receiver.CastReceiverManager.getInstance()
    window.castReceiverManager.start()
