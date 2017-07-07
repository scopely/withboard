Template.ControlLayout.onRendered ->
  @$('.button-collapse').sideNav
    closeOnClick: true

Template.ControlLayout.events
  'click .logout': (evt) ->
    evt.preventDefault()
    Meteor.logout()
    Router.go '/'