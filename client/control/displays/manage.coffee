Template.ManageDisplay.onRendered ->
  @autorun =>
    @overrideScaling.get()
    setTimeout =>
      M.Range.init @$('input[type=range]')
    , 1

Template.ManageDisplay.onCreated ->
  {fourUp, onAfter, offAfter, offDays, zoom} = @data?.config.hardware ? {}
  @dailyScheduling = new ReactiveVar(!!onAfter or !!offAfter)
  @weeklyScheduling = new ReactiveVar(!!offDays)
  @overrideScaling = new ReactiveVar(!!zoom)

Template.ManageDisplay.helpers
  objectPair: (obj) ->
    Object.keys(obj).map (k) ->
      key: k
      value: obj[k]

  dailyScheduling: ->
    Template.instance().dailyScheduling.get()
  weeklyScheduling: ->
    Template.instance().weeklyScheduling.get()
  overrideScaling: ->
    Template.instance().overrideScaling.get()

  onAfter: ->
    @config.hardware?.onAfter
      ?.map (x) -> if x < 10 then "0#{x}" else "#{x}"
      .join ':'
  offAfter: ->
    @config.hardware?.offAfter
      ?.map (x) -> if x < 10 then "0#{x}" else "#{x}"
      .join ':'
  daysOffInclude: (d) ->
    d in (@config.hardware?.daysOff ? [])

  isChromeApp: ->
    @platform is 'chrome app'

  scaleRatio: ->
    @config.hardware?.zoom or
      @status.screenSize?.width / 1280
  defaultScale: ->
    @status.screenSize?.width / 1280

Template.ManageDisplay.events

  'change [type=checkbox]': (evt) ->
    if evt.target.name in ['dailyScheduling', 'weeklyScheduling', 'overrideScaling']
      Template.instance()[evt.target.name].set evt.target.checked

  'submit [action=hardwareConfig]': (evt) ->
    evt.preventDefault()
    { fourUp, onAfter, offAfter, weeklyScheduling, scale } = evt.target

    $set = {}
    $unset = {}
    pre = 'config.hardware.'

    if fourUp.checked
      $set[pre+'fourUp'] = true
    else
      $unset[pre+'fourUp'] = true

    if onAfter and offAfter
      $set[pre+'onAfter'] = onAfter.value.split(':').map((x) -> parseInt(x))
      $set[pre+'offAfter'] = offAfter.value.split(':').map((x) -> parseInt(x))
    else
      $unset[pre+'onAfter'] = true
      $unset[pre+'offAfter'] = true

    if weeklyScheduling.checked
      offDays = []
      for dayNum in [0..6]
        if evt.target['offDay'+dayNum].checked
          offDays.push dayNum
      $set[pre+'daysOff'] = offDays
    else
      $unset[pre+'daysOff'] = true

    if scale
      $set[pre+'zoom'] = +scale.value
    else
      $unset[pre+'zoom'] = true

    console.log @_id, $set, $unset
    Displays.update @_id, {$set, $unset}
