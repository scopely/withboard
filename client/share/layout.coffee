Template.Share.onCreated ->
  @screenId = new ReactiveVar @data.screens[0]._id

  @autorun =>
    {hash} = Iron.Location.get()
    if hash.length
      @screenId.set hash.slice(1)

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
    
  wrapClass: ->
    if @screens.length > 1 then 'multi-screen' else ''