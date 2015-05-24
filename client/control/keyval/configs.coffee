Template.Configs.onRendered ->
  @autorun =>
    Config.find().fetch()
    @$('.collapsible').collapsible
      accordion: true
    for textarea in @$('textarea')
      textareaAutoResize $(textarea)

Template.Configs.events
  'submit .form-update': (event) ->
    try
      $value = $(event.target).find('textarea')
      value = JSON.parse $value.val()
      Config.update @_id, $set: {value}
    catch err
      alert 'JSON parsing error ' + err
    false

  'click .btn-delete': ->
    if confirm "Do you want to delete #{@key}?"
      Config.remove @_id

  'submit .form-create': (event) ->
    try
      {key, value} = event.target
      Config.insert
        key: key.value
        value: JSON.parse value.value

      key.value = value.value = ''
    catch err
      alert 'JSON parsing error ' + err
    false
