####################
## Access control

Template.ManageSharing.helpers
  url: ->
    path = "s/#{@_id}"
    path += "?token=#{@token}" if @token
    Meteor.absoluteUrl path

  sharingIs: (other) ->
    @sharing is other

Template.ManageSharing.events
  'click .make-public': (evt) ->
    evt.preventDefault()
    Shares.update @_id,
      $set:
        sharing: 'public'
        token: Random.secret()

  'click .make-domain': (evt) ->
    evt.preventDefault()
    Shares.update @_id,
      $set:
        sharing: 'domain'
      $unset:
        token: 1

  'click .make-myself': (evt) ->
    evt.preventDefault()
    Shares.update @_id,
      $set:
        sharing: 'myself'
      $unset:
        token: 1


#########################
## Content management

Template.ManageSharing.onCreated ->
  @viewId = new ReactiveVar

Template.ManageSharing.events
  'change select[name=view]': (event) ->
    {viewId} = Template.instance()
    viewId.set event.target.value

  'submit form[name=add-screen]': (event) ->
    event.preventDefault()
    {viewId} = Template.instance()
    screen = event.target.screen.value

    Shares.update @_id,
      $push: entries:
        type: 'screen'
        id: screen
    , (err) =>
      if err
        alert 'Problem with adding screen to share.\n\n' + err.stack
        console.log 'Adding', screen, 'to', @_id, 'error:', err

  'click .remove-entry': (evt) ->
    evt.preventDefault()
    {_id} = Template.parentData()
    Shares.update _id,
      $pull: entries:
        type: 'screen'
        id: @_id
    , (err) =>
      if err
        alert 'Problem with removing screen from share.\n\n' + err.stack
        console.log 'Removing', @_id, 'from', _id, 'error:', err

Template.ManageSharing.helpers
  modules: -> Modules.find()
  views: -> Views.find module: @_id
  view: ->
    {viewId} = Template.instance()
    Views.findOne viewId.get()
  screens: ->
    {viewId} = Template.instance()
    Screens.find view: viewId.get()

  entryScreen: ->
    @entries.map (e) ->
      Screens.findOne e.id