doGoogleLogin = (scopes, modifier='none') ->
  Meteor.loginWithGoogle
    loginStyle: if Meteor.isCordova then 'redirect' else 'popup'
    requestPermissions: scopes
    requestOfflineToken: modifier is 'offline'
  , (err) -> if err
    alert(err.message)
  false

Template.Login.events
  'click button.as-user': ->
    doGoogleLogin [
      'https://www.googleapis.com/auth/userinfo.email'
    ]

  'click button.as-admin': ->
    doGoogleLogin [
      'https://www.googleapis.com/auth/drive.readonly'
    ], 'offline'
