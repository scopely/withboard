Template.Displays.helpers
  pairCode: -> @username.slice 8
  selectedDisplay: -> Meteor.users.findOne Session.get('selected display')

  roles: -> Roles.map (role) -> {role}
  optionAttrs: (role) -> if role is @role then {selected: true} else {}

Template.Displays.events
  'click a': -> Session.set 'selected display', @_id
  'change select': (event) ->
    Meteor.call 'updateDisplay', @_id,
      role: event.target.value

Template.Displays.onRendered ->
  @autorun =>
    Meteor.users.find().fetch()
    @$('.modal-trigger').leanModal()
    @$('select').material_select()
