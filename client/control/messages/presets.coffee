Template.MessagePresets.onRendered ->
  # @$('.dropdown-button').dropdown()

Template.MessagePresets.helpers
  presets: -> [
    icon: 'restaurant'
    name: 'Lunch'
    title: 'Lunch is ready!'
    subtitle: "Today's menu: "
  ,
    icon: 'restaurant'
    name: 'Dinner'
    title: 'Dinner has arrived!'
    #subtitle: "If you ordered, your food is in the Kitchen"
    relevantTime: '10 minutes'
  ,
    icon: 'event'
    name: 'All-hands'
    title: 'Friday All-Hands – Starting now!'
    subtitle: 'Grab lunch and head down to the Pit'
  ,
    icon: 'mode_comment'
    name: 'Other'
  ]


Template.MessagePresets.events
  'click .btn-large': ->
    Session.set 'msg preset', @