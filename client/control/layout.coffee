Template.ControlLayout.onRendered ->
  window.sidenav = @sidenav = M.Sidenav.init @$('.sidenav')

Template.ControlLayout.events
  'click .logout': (evt) ->
    evt.preventDefault()
    Meteor.logout()
    Meteor.setTimeout ->
      Router.go '/'
    , 100

Template.ControlLayout.helpers
  userName: ->
    Meteor.user()?.profile.name
  orgName: ->
    Meteor.settings.public.organization_name
  logoUrl: ->
    Meteor.settings.public.assets_s3_bucket + 'logo.png'
