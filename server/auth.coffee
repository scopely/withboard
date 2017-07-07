if Meteor.settings.domain
  Accounts.config
    restrictCreationByEmailDomain: Meteor.settings.domain

# OAuth configuration
if Meteor.settings.google
  ServiceConfiguration.configurations.upsert
    service: 'google'
  , $set:
    clientId: Meteor.settings.google.id
    secret:   Meteor.settings.google.secret
