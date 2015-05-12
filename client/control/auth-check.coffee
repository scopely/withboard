loginHook = (route)->
  return @next() if route.url.slice(0, 8) isnt '/control'

  if Meteor.loggingIn()
    @render 'loading'
  else unless Meteor.userId()
    @layout false
    @render 'Login'
  else
    @next()

Router.onRun loginHook
Router.onBeforeAction loginHook
