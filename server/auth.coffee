if Meteor.settings.domain
  Accounts.config
    restrictCreationByEmailDomain: Meteor.settings.domain

# OAuth configuration
if Meteor.settings.google
  ServiceConfiguration.configurations.remove
    service: 'google'

  ServiceConfiguration.configurations.insert
    service: 'google'
    clientId: Meteor.settings.google.id
    secret:   Meteor.settings.google.secret
