Template.Displays.helpers
  selectedDisplay: -> Displays.findOne Session.get('selected display')

Template.Displays.onRendered ->
  @autorun =>
    Displays.find().fetch()
    @$('.modal-trigger').leanModal()
