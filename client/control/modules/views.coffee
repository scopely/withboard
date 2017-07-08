Template.Views.events
  'click [name=edit-view-fetcher]': (e) ->
    e.preventDefault()
    Session.set 'fetcher context',
      type: 'view'
      id: @_id
    $('#fetcher-editor').modal 'open',
      dismissible: false

  'click [name=new-view]': (e) ->
    e.preventDefault()
    Views.insert
      module: @module._id
      name: prompt 'View name'
      template:
        html: 'Hello world'
    , (err, id) -> if err
      alert "Couldn't create view.\n\n#{err.name} #{err.message}"
