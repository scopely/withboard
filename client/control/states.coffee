Template.States.onRendered ->
  @autorun =>
    State.find().fetch()
    @$('.collapsible').collapsible
      accordion: true
    for textarea in @$('textarea')
      textareaAutoResize $(textarea)

Template.States.helpers
  json: (data) -> JSON.stringify data
  shortJson: (data) ->
    if data.substr
      data.slice(0, 25) + if data.length > 25 then '...' else ''
    else if data.toFixed
      '' + data
    else
      json = JSON.stringify data
      json.slice(0, 25) + if json.length > 25 then '...' else ''

Template.States.events
  'submit .form-update': (event) ->
    try
      $value = $(event.target).find('textarea')
      value = JSON.parse $value.val()
      State.update @_id, $set: {value}
    catch err
      alert 'JSON parsing error ' + err
    false

  'click .btn-delete': ->
    if confirm "Do you want to delete #{@key}?"
      State.remove @_id

  'submit .form-create': (event) ->
    try
      {key, value} = event.target
      State.insert
        key: key.value
        value: JSON.parse value.value

      key.value = value.value = ''
    catch err
      alert 'JSON parsing error ' + err
    false
