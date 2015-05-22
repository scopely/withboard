Template.Displays.helpers
  pairCode: -> @username.slice 8
  selectedDisplay: -> Meteor.users.findOne Session.get('selected display')

Template.Displays.onRendered ->
  @autorun =>
    Meteor.users.find().fetch()
    @$('.modal-trigger').leanModal()
