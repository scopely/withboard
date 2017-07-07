Template.RenderScreen.onCreated ->
  @screenId = @data.screenId
  @viewId = new ReactiveVar
  @moduleId = new ReactiveVar
  @contextFilter = new ReactiveVar
  @templateName = new ReactiveVar

  # Resolve screen ID to a view ID
  # We only want to rerender the full HTML
  # when the *VIEW* ID changes
  @autorun =>
    if screen = Screens.findOne(@screenId.get(), fields: {view: 1})
      @viewId.set screen.view

  # Then also resolve view ID to module ID
  # Mostly autorunning for when the view changes
  @autorun =>
    if view = Views.findOne(@viewId.get(), fields: {module: 1})
      @moduleId.set view.module

  @autorun =>
    @contextFilter.set $in: [
      { type: 'module', id: @moduleId.get() }
      { type: 'screen', id: @screenId.get() }
    ]

  @templateData =
    setting: (key) =>
      context = @contextFilter.get()
      Settings.findOne({context, key})?.value
    settings: =>
      context = @contextFilter.get()
      dict = {}
      Settings.find({context}).forEach ({key, value}) ->
        dict[key] = value
      return dict
    data: (key) =>
      context = @contextFilter.get()
      Data.findOne({context, key})?.value

Template.RenderScreen.onRendered ->
  # Rerender the view's template completely
  # Store reference so it can be used
  # TODO: garbage collect old renders
  @autorun =>
    console.log 'compiling view', @viewId.get()
    if template = compileView(@viewId.get())
      data = @templateData
      Template[template].onCreated ->
        @getData = data.data
        @getSetting = data.setting
        @getSettings = data.settings

    @templateName.set template

Template.RenderScreen.helpers
  # This is totally decoupled from rendering.
  # CSS-only changes should be really cheap to apply.
  viewCss: ->
    {viewId} = Template.instance()
    if view = Views.findOne(viewId.get(), {fields: 'template.css': 1})
      return view.template.css

  # Renders the view and returns a template name
  renderedTemplate: ->
    {templateName} = Template.instance()
    templateName.get()

  # Grabs settings and data for the screen/module
  screenData: ->
    {templateData} = Template.instance()
    return templateData
