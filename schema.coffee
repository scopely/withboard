root = global ? window
root.root = root

root.Roles = ['default', 'rooms', 'recruiting', 'newrelic', 'metrics', 'titan']

root.State = new Meteor.Collection 'state'
root.Config = new Meteor.Collection 'config'

root.Displays = new Meteor.Collection 'displays'
Displays.attachSchema new SimpleSchema
  name      : type: String, optional: true
  title     : type: String, optional: true
  role      : type: String, optional: true
  config    : type: String, optional: true

  online    : type: String, optional: true
  token     : type: String, optional: true
  firstSeen : type: Date
  pairedAt  : type: Date,   optional: true