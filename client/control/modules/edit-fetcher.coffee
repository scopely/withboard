editor = null

Session.setDefault 'fetcher context', {}
Template.EditFetcherModal.onRendered -> Tracker.autorun =>
  {type, id} = Session.get 'fetcher context'
  context = switch type
    when 'module' then Modules.findOne id
    when 'view' then Views.findOne id

  if context
    Session.set 'fetcher ttl', context.ttl ? 0
    @$('#fetcherTtl').val context.ttl
    unless editor?
      editor = CodeMirror @$('.editor')[0],
        lineNumbers: true
        mode: 'coffeescript'
        theme: 'neo'
        tabSize: 2
        value: context.fetcher ? "@setData 'apps', {}"
    else
      console.log 'do we care about fetcher?'
      # context was updated. do we care?
  else
    @$('.editor').empty()
    editor = null

Template.EditFetcherModal.events
  'click .action-save': ->
    newScript = editor.getValue()

    # We get a lot of tabs.
    fixedCoffee = newScript.replace(/\t/g, '  ')
    if fixedCoffee isnt newScript.coffee
      editor.setValue fixedCoffee

    update = $set:
      fetcher: fixedCoffee
      ttl: $('#fetcherTtl').val()

    if update.$set.ttl
      update.$set.expires = new Date()

    {type, id} = Session.get 'fetcher context'
    context = switch type
      when 'module' then Modules.update id, update
      when 'view' then Views.update id, update

    Session.set 'fetcher context', false

  'click .action-cancel': ->
    Session.set 'fetcher context', false
