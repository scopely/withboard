updateOneModule = ->
  outdated = Modules.findOne
    ttl: $gt: 0
    fetcher: $ne: null
    $or: [
      { expires: null }
      { expires: $lt: new Date() }
    ]
  return unless outdated

  # Mark updated even if it failed
  # TODO: report failure
  Modules.update outdated._id, $set:
    expires: new Date(+new Date()+(outdated.ttl*1000))

  context = {type: 'module', id: outdated._id}
  config = {}
  for {key, value} in Settings.find({context}).fetch()
    config[key] = value

  console.log 'Updating', outdated.name, 'module'
  self =
    config: config
    context: context
    setData: (key, value) ->
      throw new Error "Data Key and Value are required" unless key and value
      console.log 'Setting key', key#, 'to', value
      Data.upsert {context, key}, $set:
        value: value
    getData: (key, defVal = null) ->
      Data.findOne({context, key})?.value ? defVal

  js = Meteor.call 'compileCoffee', outdated.fetcher, 'block'
  eval(js).apply self # TODO!!!
  console.log 'Done updating module'
  true

updateOneScreen = ->
  activeViews = Views.find
    ttl: $gt: 0
    fetcher: $ne: null
  ,
    fields:
      _id: 1
  .fetch().map (view) -> view._id

  outdated = Screens.findOne
    view: $in: activeViews
    $or: [
      { expires: null }
      { expires: $lt: new Date() }
    ]
  ,
    sort:
      expires: 1
  return unless outdated
  view = Views.findOne outdated.view

  # Mark updated _before_ trying fancy stuff
  Screens.update outdated._id, $set:
    expires: new Date(+new Date()+(view.ttl*1000))

  config = {}

  parentContext = {type: 'module', id: view.module}
  for {key, value} in Settings.find({context: parentContext}).fetch()
    config[key] = value

  context = {type: 'screen', id: outdated._id}
  for {key, value} in Settings.find({context}).fetch()
    config[key] = value

  console.log 'Updating', outdated.name, 'screen with config', config
  self =
    config: config
    context: context
    setData: (key, value) ->
      throw new Error "Data Key and Value are required" unless key and value
      console.log 'Setting key', key#, 'to', value
      Data.upsert {context, key}, $set:
        value: value
    getData: (key, defVal = null) ->
      Data.findOne({context, key})?.value ? defVal

  try
    js = Meteor.call 'compileCoffee', view.fetcher, 'block'
    eval(js).apply self # TODO!!!

    Screens.update outdated._id,
      $unset: failure: true

    console.log 'Done updating screen'
  catch err
    console.log 'Encountered error reloading', outdated.name, err.stack
    Screens.update outdated._id, $set:
      # TODO: back off if failing for past hour
      # TODO: maybe after there's a manual refresh button
      failure:
        message: 'Unexpected ' + err.name + ' in fetcher'
        details: err.stack
        since: outdated.failure?.since ? new Date()

  true

updateOne = ->
  try
    updateOneModule() or updateOneScreen() # or console.log('Nothing to update')
  finally
    Meteor.setTimeout updateOne, 1000

Meteor.startup ->
  Meteor.setTimeout updateOne, 1
  Meteor.setTimeout ->
    new ServiceManager()
  , 1
