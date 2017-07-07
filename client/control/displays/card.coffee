Template.DisplayCard.helpers
  displayColor: ->
    if not @token
      # waiting to pair
      'cyan lighten-3'
    else if @online
      if @online is @config?.rebootIf
        # currently rebooting (or trying)
        'deep-purple lighten-2'
      else if @status?.displayOn is false
        # running, but TV isn't showing it
        'indigo lighten-2'
      else
        # all status checks positive
        'light-green lighten-2'
    else
      # offline
      'blue-grey darken-1'

  platformIs: (vs) ->
    @platform is vs

  canReboot: ->
    @platform is 'chrome app' and @online

  can4up: ->
    @platform is 'chrome app' and @name?.includes '4K'

Template.DisplayCard.events
  'click a.rename': (evt) ->
    evt.preventDefault()
    if name = prompt 'New name for display?', @name
      Displays.update @_id, $set:
        name:  name

  'click a.delete': ->
    Displays.remove @_id

  'click a.pair': ->
    if name = prompt "Name for new display #{@_id}?"
      Displays.update @_id, $set:
        pairedAt: new Date()
        name: name
        token: Random.secret()

  'click a.reboot': ->
    Displays.update @_id, $set:
      'config.rebootIf': @online

  'click a.fourUp': ->
    Displays.update @_id, $set:
      'config.hardware.fourUp': true

  'click a.unFourUp': ->
    Displays.update @_id, $unset:
      'config.hardware.fourUp': true
