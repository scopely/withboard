Template.ModuleList.events
  'click #import-file': (evt) ->
    evt.preventDefault()
    $('#import-upload').click()

  'change #import-upload': (evt) ->
    evt.preventDefault()
    return unless file = event.target.files[0]

    reader = new FileReader
    reader.onload = (e) ->
      console.log 'Parsing file contents'
      {version, modules} = JSON.parse e.target.result
      switch version
        when 1
          importV1Modules(modules)
        else
          alert 'Unknown file version ' + version
          console.log 'Unknown file version', version
          console.groupEnd()

    console.group 'Module Import'
    console.log 'Reading', file.name
    reader.readAsText file

importV1Modules = (modules) ->
  # TODO: we assume *everything* works or *nothing* works
  # TODO: we assume you want to replace your settings

  # Debounce failure. Don't spam even if really bad stuff happens.
  # Monitor when we're all done and inform the user..
  pending = done = failed = 0
  cb = ->
    pending++
    (err) ->
      if err
        console.log 'Import problem:', err.stack
        failed++
      else
        done++

      pending--
      maybeDone()

  maybeDone = -> if pending is 0
    console.log 'Processed', done, 'database operations successfully.'
    if failed
      console.log 'Encountered', failed, 'errors during import.'
      alert 'Import failed with ' + failed + ' problem(s).\n\nCheck your web console for details.'
    else
      console.log 'Import completed without any problems.'
      alert 'Import completed successfully.'
    console.groupEnd()

  # copy modules
  for module in modules
    moduleCopy = JSON.parse JSON.stringify module
    if existingModule = Modules.findOne(name: module.name)
      Modules.update existingModule._id, $set: moduleCopy, cb()
      module._id = existingModule._id
    else
      module._id = Modules.insert moduleCopy, cb()

    # copy module settings
    context =
      type: 'module'
      id: module._id
    for setting in module.settings when setting.value
      # Spec and value are together for modules
      transformSetting setting, setting

      {key, value} = setting
      if entry = Settings.findOne {context, key}
        Settings.update entry._id, $set: {value}, cb()
      else
        Settings.insert {context, key, value}, cb()

    # copy views
    for view in module.views
      view.module = module._id
      viewCopy = JSON.parse JSON.stringify view
      viewCopy.template.scripts = [] unless viewCopy.template.scripts
      if existingView = Views.findOne(module: module._id, name: view.name)
        Views.update existingView._id, $set: viewCopy, cb()
        view._id = existingView._id
      else
        view._id = Views.insert viewCopy, cb()

      # copy screens
      for screen in view.screens
        screen.view = view._id
        screenCopy = JSON.parse JSON.stringify screen
        if existingScreen = Screens.findOne(view: view._id, name: screen.name)
          Screens.update existingScreen._id, $set: screenCopy, cb()
          screen._id = existingScreen._id
        else
          screen._id = Screens.insert screenCopy, cb()

        # copy screen settings
        context =
          type: 'screen'
          id: screen._id
        for screenSetting in screen.settings when screenSetting.value
          setting = view.settings.filter((s) -> s.key is screenSetting.key)[0]

          # Spec and value are from different sources for screens
          transformSetting screenSetting, setting

          {key, value} = screenSetting
          if entry = Settings.findOne {context, key}
            Settings.update entry._id, $set: {value}, cb()
          else
            Settings.insert {context, key, value}, cb()

  console.log 'Processed import, waiting for operations to complete...'
  maybeDone() # just in case file had nothing to do

transformSetting = (setting, spec) -> if setting.value
  switch spec.type
    when 'userId'
      if user = Meteor.users.findOne('profile.name': setting.value)
        setting.value = user._id
      else
        console.log 'No user matching', setting.value, 'found'
