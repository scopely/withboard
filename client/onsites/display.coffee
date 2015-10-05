timeDep = new Tracker.Dependency()
time = moment()

Meteor.setInterval ->
  time = moment()
  timeDep.changed()
, 60 * 1000

Template.DisplayOnsites.helpers
  time: (date) ->
    moment(date).format('h:mm A')

  day: ->
    timeDep.depend()
    time.format 'dddd'
