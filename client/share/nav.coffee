Template.ShareNav.onRendered ->
  [@sidenav] = M.Sidenav.init @$('.sidenav')

Template.ShareNav.events
  'click .sidenav a': (evt) ->
    {sidenav} = Template.instance()
    if sidenav.lastWindowWidth <= 992
      # sidebar isn't fixed open, so close it
      sidenav.close()

Template.ShareNav.helpers
  label: ->
    Session.get('display-context').title

  isActiveScreen: ->
    {screenId} = Template.parentData()
    if @_id is screenId.get() then 'active'

  userName: ->
    Meteor.user()?.profile.name ? 'Guest User'
  orgName: ->
    Meteor.settings.public.organization_name
  logoUrl: ->
    Meteor.settings.public.assets_s3_bucket + 'logo.png'
  shareName: ->
    Shares.findOne().title
