serviceFilter =
  ttl: -1
  fetcher: $ne: null

fields =
  name: 1
  fetcher: 1

root.ServiceManager =
class ServiceManager
  constructor: ->
    @modules = {}
    @views = {}

    @observeCollection Modules, @modules, ModuleService
    @observeCollection Views, @views, ViewService
    @observeSettings()

  observeCollection: (coll, cache, service) ->
    coll.find(serviceFilter, {fields}).observeChanges
      added: (id, fields) =>
        cache[id] = new service id, fields
      changed: (id, fields) => if thing = cache[id]
        if 'name' of fields
          thing.setName fields.name
        if 'fetcher' of fields
          thing.setLauncher fields.fetcher
      removed: (id) =>
        cache[id]?.stop()
        delete cache[id]

  observeSettings: ->
    @monitorSettings (type, id) => switch type
      when 'module'
        @modules[id]?.start()

        for _, view of @views
          if view.module is id
            view.start()

      when 'screen'
        for _, view of @views
          view.threads[id]?.start()

  monitorSettings: (cb) ->
    enabled = false
    Settings.find().observe
      added: (s) ->
        if enabled
          cb(s.context.type, s.context.id)
      changed: (s) ->
        cb(s.context.type, s.context.id)
    enabled = true
