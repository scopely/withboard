Template.DisplayCard.helpers
  displayColor: ->
    if not @token
      'cyan lighten-3'
    else if @online
      'light-green darken-1'
    else
      'blue-grey darken-1'

  roles: -> Roles.map (role) -> {role}
  optionAttrs: (role) -> if role is @role then {selected: true} else {}

Template.DisplayCard.events
  'click a.modal-trigger': -> Session.set 'selected display', @_id
  'click a.delete': -> Displays.remove @_id
  'click a.pair': -> Displays.update @_id, $set:
    pairedAt: new Date()
    token: Random.secret()
  'change select': (event) -> Displays.update @_id, $set:
    role: event.target.value

Template.DisplayCard.onRendered ->
  @autorun => @$('select').material_select()
