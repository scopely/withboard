Template.Login.events
  'click button': ->
    Meteor.loginWithGoogle
      loginStyle: if Meteor.isCordova then 'redirect' else 'popup'
    false
