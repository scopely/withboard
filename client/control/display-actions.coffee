Template.DisplayActions.events
  'submit .edit': (event) ->
    {name, title} = event.target
    Meteor.call 'updateDisplay', @_id,
      name:  name.value
      title: title.value
    false

  'submit .delete': (event) ->
    Meteor.call 'deleteDisplay', @_id
    false

Template.DisplayActions.onRendered ->
  @$('select').material_select()

Template.DisplayActions.helpers
  roles: -> Roles.map (role) -> {role}
  optionAttrs: (role) ->
    selected: role is @
