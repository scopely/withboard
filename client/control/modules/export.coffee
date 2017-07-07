# Export includes all modules/views/screens/settings/values
# BUT NO DATA!

Template.ModuleList.events 'click #export-all': (e) ->
  data =
    version: 1
    modules: Modules.find().fetch()

  for module in data.modules
    for setting in module.settings
      setting.value = Settings.findOne
        context: type: 'module', id: module._id
        key: setting.key
      ?.value

      # Spec and value are together for modules
      transformSetting setting, setting

    module.views = Views.find(module: module._id).fetch()
    for view in module.views

      view.screens = Screens.find(view: view._id).fetch()
      for screen in view.screens

        screen.settings = view.settings.map (setting) ->
          entry = Settings.findOne
            context: type: 'screen', id: screen._id
            key: setting.key

          screenSetting =
            key: setting.key
            value: entry?.value

          # Spec and value are from different sources for screens
          transformSetting screenSetting, setting
          return screenSetting

        delete screen._id
        delete screen.view
      delete view._id
      delete view.module
    delete module._id

  blob = new Blob [JSON.stringify(data)],
    type: 'application/json'
  e.target.href = window.URL.createObjectURL(blob)
  e.target.download = 'withboard-modules.json'

transformSetting = (setting, spec) -> if setting.value
  switch spec.type
    when 'userId'
      if user = Meteor.users.findOne(setting.value)
        setting.value = user.profile.name
