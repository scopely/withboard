Template.NewMessage.onCreated ->
  @icon = new ReactiveVar Session.get('msg preset').icon
  @feedback = new ReactiveVar

  Meteor.call 'ping', (err, {serverMillis}) =>
    @offset = +new Date() - serverMillis

Template.NewMessage.onRendered ->
  @$('[data-activates=icons]').dropdown
    constrain_width: false
  @$('select').material_select()
  Materialize.updateTextFields()

Template.NewMessage.helpers
  preset: (key) ->
    Session.get('msg preset')[key]

  icon: ->
    {icon} = Template.instance()
    icon.get()

  feedback: ->
    {feedback} = Template.instance()
    feedback.get()

  icons: -> [
    'mode_comment'
    'restaurant'
    'event'
    'phone_android'
    'headset'
    'videogame_asset'
    'mail'
    'event_note'
    'assignment'
    'directions_car'
    'directions_run'
    'directions_bike'
    'lightbulb_outline'
    'schedule'
    'room'
    'thumb_up'
    'whatshot'
    'arrow_forward'
    'local_cafe'
    'local_bar'
    'local_drink'
    'local_movies'
    'local_pizza'
    'timer'
    'photo_camera'
    'brightness_low'
    'weekend'
    'flag'
  ]

Template.NewMessage.events
  'click .select-icon': (evt) ->
    evt.preventDefault()
    {icon} = Template.instance()
    icon.set @toString() # gets split up normally

  'click [name=cancel]': ->
    Session.set 'msg preset'

  'click [href=#importance-modal]': (evt) ->
    evt.preventDefault()
    $('#importance-modal').openModal()

  'submit form': (evt) ->
    evt.preventDefault()
    {icon, feedback} = Template.instance()
    {title, subtitle, priority} = evt.target

    feedback.set
      text: 'Creating message...'
      color: 'green'

    displayMinutes = switch +priority.value
      when 1 then 15 # 5, 10
      when 2 then 6  # 1,  5
      when 3 then 3  # 0,  3

    serverMoment = moment().subtract(@offset)
    startMoment = serverMoment.clone().add(5, 'seconds')
    endMoment = startMoment.clone().add(displayMinutes, 'minutes')

    Messages.insert
      owner: Meteor.userId()
      type: 'notification'
      priority: +priority.value

      icon: icon.get()
      title: title.value
      subtitle: subtitle.value

      createdAt: serverMoment.toDate()
      enableAt: startMoment.toDate()
      expireAt: endMoment.toDate()

    , (err, _id) ->
      if err
        feedback.set
          text: err.message
          color: 'red'
      else
        feedback.set
          text: 'All good!'
          color: 'green'

        # Close editing soon
        setTimeout ->
          Session.set 'msg preset'
        , 1500
