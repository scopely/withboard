Template.EditViewScripts.onRendered ->
  @autorun =>
    if scriptKey = Session.get 'script key'
      editor = @$('.script-editor')[0].cm

      if scriptKey is 'new'
        editor.setValue '(event) ->\n  # logic goes here'

      else if script = @data.template.scripts?.filter(({key}) -> key is scriptKey)[0]
        editor.setValue script.coffee

Template.EditViewScripts.events

  'click .select-script': (evt) ->
    evt.preventDefault()
    Session.set 'script key', @key

  'click #new-script': (evt) ->
    evt.preventDefault()
    Session.set 'script key', 'new'

  'click #cancel-script': (evt) ->
    if 'new' is Session.get 'script key'
      Session.set 'script key', false

  'click #delete-script': (evt) ->
    key = Session.get 'script key'
    if key and key isnt 'new'
      Views.update @_id, $pull:
        'template.scripts': {key}
      Session.set 'script key', false

  'submit #edit-script': (evt) ->
    evt.preventDefault()
    return unless key = Session.get 'script key'

    {cm} = $('.script-editor')[0]
    newScript =
      coffee: cm.getValue()

    # We get a lot of tabs.
    fixedCoffee = newScript.coffee.replace(/\t/g, '  ')
    if fixedCoffee isnt newScript.coffee
      cm.setValue fixedCoffee

    if key is 'new'
      newScript.hook = evt.target.hook.value
      newScript.param = evt.target.param.value
    else
      [newScript.hook, newScript.param] = key.split ':'

    switch newScript.hook
      when 'helper', 'event', 'hook'
        unless newScript.param
          alert "Helpers, events, and hooks require specifying a name parameter"
          return
        newScript.key = "#{newScript.hook}:#{newScript.param}"
      when 'on-create', 'on-render', 'on-destroy'
        newScript.key = newScript.hook
      else
        alert "huh"
        return

    Meteor.call 'compileCoffee', newScript.coffee, 'function', (err, js) =>
      newScript.js = js
      if err
        alert err.message

      else if @template.scripts?.some((script) -> script.key is key)
        # TODO
        ###
        Views.update
          _id: view
          'template.scripts.key': newScript.key
        , $set:
          'template.scripts.$': newScript
        ###
        Meteor.call 'updateScript', @_id, newScript, (err) ->
          if err
            alert 'Problem updating script. ' + err.message
            console.log 'Problem updating script:', err.stack

      else if key is 'new'
        Views.update @_id, $push:
          'template.scripts': newScript
        , (err) ->
          if err
            alert 'Problem adding script. ' + err.message
            console.log 'Problem adding script:', err.stack
          else
            Session.set 'script key', newScript.key

      else
        alert 'Uh, nothing happened.'
        console.log "Uh, dont know how to update script", key, 'on', @_id

Template.EditViewScripts.helpers
  script: -> if selectedKey = Session.get 'script key'
    if selectedKey is 'new' then {}
    else
      {template} = Template.currentData()
      template.scripts?.some ({key}) ->
        key is selectedKey

  itemClass: ->
    if Session.get('script key') is @key then 'active'

  newScript: -> if key = Session.get 'script key'
    key is 'new'
  existingScript: -> if key = Session.get 'script key'
    key and key isnt 'new'
