#########################
## Content management

Template.ManageSharing.onCreated ->
  @viewId = new ReactiveVar

Template.ManageSharing.events
  'change select[name=view]': (event) ->
    {viewId} = Template.instance()
    viewId.set event.target.value

  'submit form[name=add-screen]': (event) ->
    event.preventDefault()
    {viewId} = Template.instance()
    screen = event.target.screen.value

    if @entries.some (e) -> e.type is 'screen' and e.id is screen
      return alert "That screen is already in this share"

    Shares.update @_id,
      $push: entries:
        type: 'screen'
        id: screen
    , (err) =>
      if err
        alert 'Problem with adding screen to share.\n\n' + err.stack
        console.log 'Adding', screen, 'to', @_id, 'error:', err

  'click .remove-entry': (evt) ->
    evt.preventDefault()
    {_id} = Template.parentData()
    Shares.update _id,
      $pull: entries:
        type: 'screen'
        id: @_id
    , (err) =>
      if err
        alert 'Problem with removing screen from share.\n\n' + err.stack
        console.log 'Removing', @_id, 'from', _id, 'error:', err

Template.ManageSharing.helpers
  modules: -> Modules.find()
  views: -> Views.find module: @_id
  view: ->
    {viewId} = Template.instance()
    Views.findOne viewId.get()
  screens: ->
    {viewId} = Template.instance()
    Screens.find view: viewId.get()

  entryScreen: ->
    @entries?.map (e) ->
      Screens.findOne(e.id) ? {_id: e.id, name: '(deleted)'}


#########################
## Administrative

Template.ManageSharing.events
  'click a[name=delete]': (evt) ->
    evt.preventDefault()
    if confirm "Really delete?"
      Shares.remove @_id, (err) ->
        if err then alert err
        else Router.go '/sharing'


#########################
## View log

Template.ManageSharing.helpers
  logEntry: ->
    ShareLog.find {share: @_id},
      sort: startedAt: -1
      limit: 25

  viewedScreens: ->
    Screens.find
      _id: $in: @screenSet

  fromNow: (time) -> if time
    Chronos.liveMoment()
    moment(time).fromNow()

  duration: ->
    isLive = !@endedAt
    suffix = ''
    if isLive
      Chronos.liveMoment()
      suffix = '+'
    msDiff = moment(@endedAt or new Date) - moment(@startedAt)
    duration = moment.duration(msDiff)
    days = parseInt(duration.as('days'))
    hours = duration.get('hours')
    minutes = duration.get('minutes')
    if days > 0
      "#{days}d #{hours}hr" + suffix
    else if hours > 0
      "#{hours}hr" + suffix
    else
      "#{minutes}min" + suffix

  showViewers: (share) ->
    share.owner is Meteor.userId()

  viewerDesc: ->
    if @viewer
      Meteor.users.findOne(@viewer).profile.name
    else @ipAddress or 'Guest'
