root.Displays = new Meteor.Collection 'displays'
Displays.attachSchema new SimpleSchema
  name      : type: String, optional: true
  title     : type: String, optional: true

  # ASSIGNMENTs
  view      : type: String, optional: true
  screen    : type: String, optional: true

  # each of these has view and screen
  panes     : type: Object, optional: true, blackbox: true

  # DEVICE SETTINGs/DATA
  platform  : type: String, optional: true
  config    : type: Object, blackbox: true, defaultValue: {}
  status    : type: Object, blackbox: true, defaultValue: {}

  # TRACKING
  online    : type: String, optional: true
  token     : type: String, optional: true
  firstSeen : type: Date
  lastSeen  : type: Date,   optional: true # When offline, the last time it was seen
  firstIp   : type: String
  latestIp  : type: String
  pairedAt  : type: Date,   optional: true


Setting = new SimpleSchema
  key       : type: String
  label     : type: String
  type      : type: String, allowedValues: ['choice', 'string', 'secret', 'url', 'number', 'userId']
  #defVal    : type: String, optional: true

Template = new SimpleSchema
  html      : type: String
  css       : type: String, optional: true
  scripts   : type: [new SimpleSchema
    key     : type: String
    hook    : type: String, allowedValues: ['on-render', 'on-create', 'on-destroy', 'helper', 'event', 'hook']
    param   : type: String, optional: true
    coffee  : type: String
    js      : type: String
  ], defaultValue: []

Context = new SimpleSchema
  type      : type: String, allowedValues: ['global', 'module', 'view', 'screen']
  id        : type: String


root.Modules = new Meteor.Collection 'modules'
Modules.attachSchema new SimpleSchema
  name      : type: String
  version   : type: String
  #author    : type: String

  ttl       : type: Number, optional: true
  fetcher   : type: String, optional: true
  expires   : type: Date, optional: true # for TTLd fetchers

  settings  : type: [Setting], defaultValue: []

root.Views = new Meteor.Collection 'views'
Views.attachSchema new SimpleSchema
  module    : type: String
  name      : type: String
  template  : type: Template

  ttl       : type: Number, optional: true
  fetcher   : type: String, optional: true

  settings  : type: [Setting], defaultValue: []

root.Screens = new Meteor.Collection 'screens'
Screens.attachSchema new SimpleSchema
  view      : type: String
  name      : type: String
  expires   : type: Date, optional: true # for TTLd fetchers

  failure   : type: new SimpleSchema(
    message : type: String
    details : type: String, optional: true
    since   : type: Date
  ), optional: true

root.Settings = new Meteor.Collection 'settings'
Settings.attachSchema new SimpleSchema
  context   : type: Context
  key       : type: String
  value     : type: String

root.Data = new Meteor.Collection 'data'
###
Data.attachSchema new SimpleSchema
  context   : type: Context
  key       : type: String
  expires   : type: Date, optional: true # for TTLd fetchers
  value     : type: Object, blackbox: true
###

root.Messages = new Meteor.Collection 'messages'
Messages.attachSchema new SimpleSchema
  owner     : type: String
  type      : type: String, allowedValues: ['notification', 'sound', 'event'] # ...
  priority  : type: Number, allowedValues: [1, 2, 3] # lowest is most urgent

  # for notifications
  icon      : type: String
  title     : type: String
  subtitle  : type: String, optional: true

  createdAt : type: Date
  enableAt  : type: Date
  expireAt  : type: Date

root.Shares = new Meteor.Collection 'shares'
Shares.attachSchema new SimpleSchema
  owner     : type: String
  title     : type: String
  entries   : type: [Context], defaultValue: []

  sharing   : type: String, allowedValues: ['myself', 'unlisted', 'domain', 'public']
  token     : type: String, optional: true
