Template.Share.onCreated ->
  @screenId = new ReactiveVar @data.screens[0]?._id

  @autorun =>
    {hash} = Iron.Location.get()
    if hash.length
      @screenId.set hash.slice(1)

  # record the current screen in the viewing session
  @autorun =>
    log = ShareLog.findOne()
    return unless log
    screen = @screenId.get()
    return if log.screenSet.includes screen
    ShareLog.update log._id,
      $addToSet:
        screenSet: screen

  $('html').attr 'id', 'display'
           .addClass 'shared'

Template.Share.helpers
  screenId: ->
    Template.instance().screenId

  canvasBg: ->
    {color} = Session.get 'display-context'
    color or '#fff' # TODO: change for projectors

  multiScreen: ->
    @screens.length > 1
  hasScreens: ->
    @screens.length > 0
