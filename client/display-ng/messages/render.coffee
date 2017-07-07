getScreenFailure = ->
  display = Displays.findOne(Session.get('display id'))
  Screens.findOne(display?.screen)?.failure

Template.RenderMessage.helpers
  message: ->
    {renderedId} = Template.instance()
    if renderedId.get() is 'fetcher failure'
      failure = getScreenFailure()

      icon: 'error'
      title: 'Sync failed :('
      subtitle: failure?.message + '.
        Failing since ' + moment(failure?.since).fromNow()
    else
      Messages.findOne renderedId.get()

  sizeClass: ->
    {renderedSize} = Template.instance()
    return 'message-' + renderedSize.get()

Template.RenderMessage.onCreated ->
  @renderedId = new ReactiveVar
  @renderedSize = new ReactiveVar 'full' # or small
  @offset = new ReactiveVar 0
  @hiding = false

  # TODO: be more centralized, also report this
  Meteor.call 'ping', (err, {serverMillis}) =>
    @offset.set(+new Date() - serverMillis)

Template.RenderMessage.onRendered -> @autorun =>
  # Fetch the nearest message
  now = Chronos.liveMoment().subtract(@offset.get())
  msg = Messages.findOne
    enableAt: $lte: now.toDate()
    expireAt: $gt: now.toDate()
  ,
    sort:
      createdAt: -1
    fields:
      _id: 1
      enableAt: 1
      expireAt: 1
      priority: 1

  size = if msg?.expireAt
    fullMinutes = switch msg.priority
      when 1 then 5 # then 10
      when 2 then 1 # then 5
      when 3 then 0 # then 3

    shrinkAt = moment(msg.enableAt).add(fullMinutes, 'minutes')
    if shrinkAt.isAfter(now) then 'full' else 'small'
  else 'full'

  # Invent a message if our fetcher is fudged
  if !msg and failure = getScreenFailure()
    if now.isAfter(moment(failure.since).add(10, 'minutes'))
      msg =
        _id: 'fetcher failure'
        enableAt: failure.since
      size = 'full'

  return if msg?._id is @renderedId.get() and size is @renderedSize.get()
  console.log msg?._id, @renderedId.get(), size, @renderedSize.get()
  return if @hiding

  if currentId = @renderedId.get()
    # Hide the rendered message
    @$('.modal').closeModal
      out_duration: 2000

      # Stop rendering once it's gone
      complete: Meteor.bindEnvironment =>
        # only clear if still on the same message
        @hiding = false
        if @renderedId.get() is currentId
          @renderedId.set()
          @renderedSize.set('full')
    @hiding = true

  else if msg
    # Render the new message
    @renderedId.set msg._id
    @renderedSize.set size

    # Open the dialog after it renders
    setTimeout =>
      @$('.modal').openModal
        dismissible: false
        opacity: if size is 'full' then 0.5 else 0.15
        in_duration: 600
    , 0
