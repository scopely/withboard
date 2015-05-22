Template.DisplayRooms.helpers
  values: (cals) ->
    if !cals
      []
    else
      _.sortBy Object.keys(cals).map((calId) ->
        cals[calId].id = calId
        cals[calId]
      ), 'summary'

  isImportant: (calId) ->
    return Config.findOne(key: 'important-cals').value.indexOf(calId) > -1

Template.DisplayRoom.helpers
  firstName: (user) ->
    if user and user.displayName
      user.displayName.split(' ')[0]
    else
      'n/a'

  upcoming: (events) ->
    return _.sortBy events, (event) ->
      +moment(event.start.dateTime)

  format: (date) ->
    moment(date.dateTime).fromNow()

  getState: (startTime, endTime) ->
    start = moment startTime.dateTime
    end   = moment   endTime.dateTime

    if start.isAfter()
      'future'
    else if end.isBefore()
      'past'
    else
      'present'

  explain: (startTime, endTime) ->
    start = moment startTime.dateTime
    end   = moment   endTime.dateTime

    if start.isAfter()
      'starts ' + start.fromNow()
    else if end.isBefore()
      'ended'
    else
      'ends ' + end.fromNow()

  hasPassed: (date) ->
    moment(date.dateTime).isBefore()

  scheduleState: (items) ->
    relevant = items.filter (item) ->
      moment(item.end.dateTime).isAfter()

    if relevant.length
      'booked'
    else
      'empty'
