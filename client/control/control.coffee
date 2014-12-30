Template.ControlHome.events
  'click #pair': ->
    code = $('#tvid').val()
    console.log 'Attempting to pair to display', code

    Meteor.subscribe 'pair', code, ->
      console.log 'Pairing might have worked'

Template.DisplayCard.events
  'submit form': (event) ->
    Meteor.call 'updateDisplay', event.target._id.value,
      name:  event.target.name.value
      title: event.target.title.value
      role:  event.target.role.value
    false

Template.DisplayCard.helpers
  roles: ->
    Roles.map (role) ->
      role: role

Template.States.events
  'submit .form-update': (event) ->
    State.update event.target._id.value,
      $set:
        value: JSON.parse event.target.value.value
    false

  'submit .form-create': (event) ->
    State.insert
      key: event.target.key.value
      value: JSON.parse event.target.value.value

    event.target.key.value = ''
    event.target.value.value = ''
    false

Template.Configs.events
  'submit .form-update': (event) ->
    Config.update event.target._id.value,
      $set:
        value: JSON.parse event.target.value.value
    false

  'submit .form-create': (event) ->
    Config.insert
      key: event.target.key.value
      value: JSON.parse event.target.value.value

    event.target.key.value = ''
    event.target.value.value = ''
    false

Template.KeyValueCard.helpers
  json: (data) ->
    JSON.stringify data

Template.ControlLayout.helpers
  collSize: (coll) ->
    window[coll].find().count()
