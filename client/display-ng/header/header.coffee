Session.set 'is loading', true

Template.LeanHeader.onCreated ->
  # set up clock timer
  @timer = new Chronos.Timer 5000
  @timer.start()

  # stash "now" into a reactive var
  @time = new ReactiveVar moment()
  @autorun =>
    @timer.dep()
    @time.set moment()

Template.LeanHeader.onDestroyed ->
  @timer.stop()


Template.LeanHeader.helpers
  clock: (timeFormat) ->
    {time} = Template.instance()
    time.get().format timeFormat

  label: ->
    {title} = Session.get 'display-context'
    window.castReceiverManager?.setApplicationState title
    return title ? Meteor.settings.public.organization_name

  imageUrl: ->
    {icon} = Session.get 'display-context'
    icon

  logoUrl: ->
    Meteor.settings.public.assets_s3_bucket + 'logo.png'

  headerAttrs: ->
    {color} = Session.get 'display-context'
    if color
      style: 'color: #fff'
    else {}

  connectionIcon: ->
    if Session.get 'is errored'
      'sync_problem'
    else if Screens.findOne()?.failure
      'sync_problem'
    else if Meteor.status().connected
      'cloud_done'
    else
      'cloud_off'

  loading: ->
    Session.get 'is loading'

  primarySurface: ->
    not Session.get('pane')
