Router.route 'displayHome',
  path: '/display'
  template: 'DisplayHome'
  layoutTemplate: 'Display'

addRole = (name, cb) ->
  Router.route "display#{name}",
    path: "/display/#{name.toLowerCase()}"
    template: "Display#{name}"
    layoutTemplate: 'Display'
    data: cb

addRole 'Rooms', -> cals: State.findOne key: 'calendars'
addRole 'Recruiting', ->  State.findOne key: 'recruiting-list'
addRole 'Onsites', ->     guests: State.findOne(key: 'onsites')?.value
addRole 'Newrelic', ->    State.findOne key: 'newrelic'
addRole 'Metrics', ->     Config.findOne key: 'metric-layout'
addRole 'Titan', ->  url: Config.findOne key: 'titan-url'
addRole 'Welcome', -> {}
addRole 'Kudos', ->  display: Displays.findOne()
addRole 'Holiday', -> {}
addRole 'Iframe', -> display: Displays.findOne()
addRole 'Rss', ->    display: Displays.findOne()
addRole 'Image', ->  display: Displays.findOne()

# Serves as a catchall so missing roles still load the Display
Router.route 'displayRoles',
    path: '/display/:role'
    template: 'DisplayDefault'
    layoutTemplate: 'Display'
