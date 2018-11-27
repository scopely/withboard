{bugsnag_key} = Meteor.settings.public
if bugsnag_key
  window.bugsnagClient = bugsnag bugsnag_key
