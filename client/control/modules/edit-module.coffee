Template.EditModule.events
  'click [name=new-setting]': (e) ->
    e.preventDefault()

    Modules.update @_id, $push: settings:
      key: prompt 'Setting key'
      label: prompt 'Setting label'
      type: prompt 'Setting type', 'string'
    , (err) -> if err
      alert "Couldn't create setting.\n\n#{err.name} #{err.message}"

  'click [name=edit-fetcher]': (e) ->
    Session.set 'fetcher context',
      type: 'module'
      id: @_id
    $('#fetcher-editor').modal 'open',
      dismissible: false
