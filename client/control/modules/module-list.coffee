Template.ModuleList.events
  'click [name=new-module]': (e) ->
    e.preventDefault()

    Modules.insert
      name: prompt 'Module name'
      version: prompt 'Module version', '0.1.0'
    , (err, id) -> if err
      alert "Couldn't create module.\n\n#{err.name} #{err.message}"

Template.ModuleList.helpers
  views: ->
    Views.find
      module: @_id
    ,
      sort: name: 1