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
addRole 'Recruiting',  -> State.findOne key: 'recruiting-list'
addRole 'Newrelic',  ->   State.findOne key: 'newrelic'
addRole 'Metrics', ->     Config.findOne key: 'metric-layout'
addRole 'Titan', ->  url: Config.findOne key: 'titan-url'

Router.route "displayPairing",
  path: "/display/pairing"
  template: "DisplayPairing"
  layoutTemplate: 'Display'
  data: -> if display = Displays.findOne()
    code: display._id

# Serves as a catchall so missing roles still load the Display
Router.route 'displayRoles',
    path: '/display/:role'
    template: 'DisplayDefault'
    layoutTemplate: 'Display'
