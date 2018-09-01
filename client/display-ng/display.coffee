Template.DisplayNg.onCreated ->
  @screenId = new ReactiveVar

Template.DisplayNg.helpers
  # flatten to a bool so it doesn't invalidate when assignment changes
  hasScreen: ->
    !!Template.instance().screenId.get()
  screenId: ->
    Template.instance().screenId

  canvasBg: ->
    {color} = Session.get 'display-context'
    color or '#fff' # TODO: change for projectors

  showMessages: ->
    if d = Displays.findOne(Session.get 'display id')
      d.name?.indexOf('Gamewall') is -1 and d.name?[0] isnt '['

sub = null
owner = null
Session.set 'display id', null # reset through hot reload # TODO: does anything actually use this?
Template.DisplayNg.onRendered ->
  console.log 'rendering display'

  # Panes are secondary view surfaces on a single multiplexed Display
  # The non-pane view surface acts as a master and communicates with hardware
  # All other view surfaces (panes) don't event think about what's above them.
  {pane} = Iron.Location.get().queryObject

  @autorun =>
    console.log 'updating display assignment'
    if display = Displays.findOne({}, fields: {token: 1, screen: 1, panes: 1})
      if display.token
        Session.set 'screen ng token', display.token
      Session.set 'display id', display._id

      if pane
        @screenId.set display.panes?[pane]?.screen
      else
        @screenId.set display.screen

    else
      @screenId.set null
      # was our display deleted?
      if Session.get 'display id'
        console.log 'resetting token'
        Session.set 'screen ng token', false
        Session.set 'display id', false
      else
        console.log 'no display yet'

  # Panes should not do any other logic
  Session.set 'pane', pane
  return if pane

  @autorun ->
    if display = Displays.findOne({}, fields: {platform: 1})
      if platform = Session.get 'platform'
        if display.platform isnt platform
          # TODO: send something we can auth with
          Meteor.call 'setPlatform', display._id, platform

  # If we are logged in, report so
  # This will get replaced by any receiver status
  @autorun ->
    if userId = Meteor.userId()
      if id = Session.get 'display id'
        Meteor.call 'setStatus', id,
          userId: Meteor.userId()

  # Support Chromecast receivers
  # Ack that we started
  # Try submitting basic status info too
  if cast?.receiver and location.hostname isnt 'localhost'
    window.castReceiverManager = cast.receiver.CastReceiverManager.getInstance()
    window.castReceiverManager.start()
    Session.set 'platform', 'chromecast'

    # Report basic data to Withboard
    submitData = ->
      if id = Session.get 'display id'
        if data = window.castReceiverManager.getApplicationData()
          Meteor.call 'setStatus', id, data
    setInterval submitData, 15 * 60 * 1000 # every 15 minutes
    setTimeout submitData, 15 * 1000 # after 10 seconds

  # Support ChromeOS/Chromebit receivers
  # We have more flexibility with this hardware
  # Esp display power toggling and signalling shutdown
  # Possibly also sourcing identity from the Chromebit
  # Or reporting hardware info, LAN IP, RAM usage, etc.
  # All communicatoin is done with IPC to Withboard Display app
  window.addEventListener 'message', (event) ->
    return if event.source is event.target
    return unless event.data?.constructor is Object
    return unless event.data.command

    owner = event.source

    switch event.data.command
      when 'startup'
        Session.set 'platform', 'chrome app'

        # ask for state, we are ready
        sendParentMessage
          command: 'getState'

        Tracker.autorun ->
          if display = Displays.findOne({}, fields: {'config.hardware': 1})
            sendParentMessage
              command: 'config'
              config: display.config?.hardware ? {}

        Tracker.autorun ->
          # Signal for reboot if we are supposed to
          # Only do so if the command is for this actual session
          display = Displays.findOne {}, fields: {config: 1, online: 1}
          rebootIf = display?.config?.rebootIf
          if rebootIf and rebootIf is display?.online
            console.log 'Signalling for reboot, token', rebootIf
            sendParentMessage
              command: 'reboot'

      when 'state'
        if display = Displays.findOne()
          Meteor.call 'setStatus', display._id, event.data.fields

  sendParentMessage = (data) -> if owner
    owner.postMessage(data, '*')
    console.log 'Sent parent event', data
