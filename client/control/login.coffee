Template.Login.events
  'click button': ->
    Meteor.loginWithGoogle
      loginStyle: if Meteor.isCordova then 'redirect' else 'popup'
      #requestPermissions: [
      #  'https://www.googleapis.com/auth/userinfo.email'
      #  'https://www.googleapis.com/auth/drive.readonly'
      #]
      #requestOfflineToken: true
      #forceApprovalPrompt: true
    , (err) -> if err
      console.log 'Signin problem:', err.stack
    false
