Template.Login.events
  'click button': ->
    Meteor.loginWithGoogle
      loginStyle: if Meteor.isCordova then 'redirect' else 'popup'
      requestPermissions: ['https://www.googleapis.com/auth/drive.readonly']
      requestOfflineToken: true
    false
