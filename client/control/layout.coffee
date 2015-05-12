Template.ControlLayout.onRendered ->
  @$('.button-collapse').sideNav
    closeOnClick: true

Template.ControlLayout.events
  'click .logout': -> Meteor.logout(); false
