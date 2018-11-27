loginHook = (route) ->
  return @next() if route.url.slice(0, 8) is '/display'

  if Meteor.loggingIn()
    @render 'Loading'
  else if Meteor.userId()
    @next()
  else if @params.query.token
    # Probably a public share link. Don't worry about auth
    @next()
  else
    @layout false
    @render 'Login'

Router.onRun loginHook
Router.onBeforeAction loginHook
