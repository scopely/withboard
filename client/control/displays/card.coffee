Template.DisplayCard.helpers
  displayColor: -> if @online then 'light-green' else 'blue-grey'

  roles: -> Roles.map (role) -> {role}
  optionAttrs: (role) -> if role is @role then {selected: true} else {}

Template.DisplayCard.events
  'click a': -> Session.set 'selected display', @_id
  'change select': (event) ->
    Meteor.call 'updateDisplay', @_id,
      role: event.target.value

Template.DisplayCard.onRendered ->
  @autorun => @$('select').material_select()
