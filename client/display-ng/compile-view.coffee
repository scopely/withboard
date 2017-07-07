Session.set 'display-context', {}

# Call a hook on an instance
Blaze.TemplateInstance.prototype.hook = (key, args...) ->
  {hooks} = @view.template
  hooks[key]?.apply @, args

# Register hooks on a template
Blaze.Template.prototype.registerHook = (key, hook) ->
  if key of @hooks
    throw new Meteor.Error 'hook-exists', "Template hook already exists"
  @hooks[key] = hook

window.compileView = (viewId) ->
  view = Views.findOne viewId, fields:
    'template.html': 1
    'template.scripts': 1
  return unless view?.template?.html
  name = ['View', viewId, Random.id(4)].join '_'

  try
    compiled = SpacebarsCompiler.compile view.template.html,
      isTemplate: true

    renderer = eval(compiled)
    UI.Template.__define__ name, renderer
  catch err
    console.log 'Error compiling', viewId, 'template:', view
    console.log err
    return
    # TODO: report error

  Template[name].onRendered ->
    Session.set 'is loading', false
    Session.set 'is errored', false
  Template[name].onDestroyed ->
    Session.set 'is loading', true

  # init hook system
  Template[name].hooks = {}

  view.template.scripts?.forEach ({key, hook, param, js}) ->
    try
      inner = eval(js)()
    catch err
      console.log "Couldn't compile", key, "for", name, '-', err
      return

    func = -> try
      inner.apply(@, arguments)
    catch err
      stack = err.stack.split('Object.eval')[0]
      [_, lineNum, charNum] = err.stack.match(/<anonymous>:(\d+):(\d+)/)
      stack += "#{key} (#{lineNum}:#{charNum} for view #{viewId})"
      console.log stack

      line = js.split('\n')[lineNum-1]
      console.log 'Responsible line:', line

      # TODO: report error

    switch hook
      when 'helper'
        Template[name].helpers { "#{param}": func }

      when 'event'
        Template[name].events { "#{param}": func }

      when 'hook'
        Template[name].registerHook param, func

      when 'on-create'
        Template[name].onCreated func

      when 'on-render'
        Template[name].onRendered func

      when 'on-destroy'
        Template[name].onDestroyed func


  # Context hooks
  Template[name].onCreated ->
    @autorun =>
      # The context hook should return an object with any of these keys:
      #   title - What this display should be visually labeled
      #   icon - URL to image to show in the header
      #   color - Background color behind the content
      Session.set 'display-context', @hook('context') ? {}
  Template[name].onDestroyed ->
    Session.set 'display-context', {}

  return name
