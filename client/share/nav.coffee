Template.ShareNav.onRendered ->
  @$('.button-collapse').sideNav
    closeOnClick: false # we do this ourselves

Template.ShareNav.events
  'click .side-nav a': (evt) ->
    if parseInt($('#canvas').css('padding-left')) < 200
      # sidebar isn't fixed open, so close it
      $('.button-collapse').sideNav 'hide'

Template.ShareNav.helpers
  label: ->
    Session.get('display-context').title

  isActiveScreen: ->
    {screenId} = Template.parentData()
    if @_id is screenId.get() then 'active'
