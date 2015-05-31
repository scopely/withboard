Template.DisplayActions.events
  'submit .edit': (event) ->
    {name, title} = event.target
    Displays.update @_id, $set:
      name:  name.value
      title: title.value
    false

  'submit .delete': (event) ->
    Displays.remove @_id
    false

Template.DisplayActions.onRendered ->
  @$('select').material_select()

Template.DisplayActions.helpers
  roles: -> Roles.map (role) -> {role}
  optionAttrs: (role) ->
    selected: role is @
