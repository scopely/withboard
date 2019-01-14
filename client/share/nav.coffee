Template.ShareNav.onRendered ->
  @autorun =>
    Template.currentData()
    [@sidenav] = M.Sidenav.init @$('.sidenav')

Template.ShareNav.events
  'click .sidenav a': (evt) ->
    {sidenav, data} = Template.instance()
    if sidenav.lastWindowWidth <= 992 or not data.forceOpen
      # sidebar isn't fixed open, so close it
      sidenav.close()

Template.ShareNav.helpers
  label: ->
    Session.get('display-context').title

  isActiveScreen: ->
    {screenId} = Template.parentData()
    if @_id is screenId.get() then 'active'
  ulClasses: -> [
    'sidenav'
    if @forceOpen then 'sidenav-fixed'
  ].join ' '

  userName: ->
    Meteor.user()?.profile.name ? 'Guest User'
  orgName: ->
    Meteor.settings.public.organization_name
  logoUrl: ->
    Meteor.settings.public.assets_s3_bucket + 'logo.png'
  shareName: ->
    Shares.findOne().title
