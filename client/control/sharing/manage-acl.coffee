####################
## Access control

Template.ManageSharingACLCard.onCreated ->
  @isExpanded = new ReactiveVar false

Template.ManageSharingACLCard.helpers
  isExpanded: ->
    Template.instance().isExpanded.get()

  url: ->
    path = "s/#{@_id}"
    path += "?token=#{@token}" if @token
    Meteor.absoluteUrl path

  sharingIs: (other) ->
    @sharing is other

  aclIcon: ->
    switch @sharing
      when 'myself' then 'person'
      when 'domain' then 'domain'
      when 'public' then 'public'

Template.ManageSharingACLCard.events
  'click .toggle-expand': (evt) ->
    evt.preventDefault()
    {isExpanded} = Template.instance()
    isExpanded.set !isExpanded.get()

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
