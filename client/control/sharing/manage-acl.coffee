####################
## Access control

Template.ManageSharingACLCard.helpers
  url: ->
    path = "s/#{@_id}"
    path += "?token=#{@token}" if @token
    Meteor.absoluteUrl path

  sharingIs: (other) ->
    @sharing is other

Template.ManageSharingACLCard.events
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
