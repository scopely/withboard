#Template.DisplaySwap.helpers

Template.DisplaySwap.events
  'submit form': (evt) ->
    evt.preventDefault()

    oldDisplay = Displays.findOne evt.target.prevDisplay.value
    newDisplay = Displays.findOne @newDisplay._id

    setFields =
      pairedAt: new Date()
      token: Random.secret()

    for field in ['name', 'title', 'view', 'screen', 'panes', 'config']
      if oldDisplay[field]
        setFields[field] = oldDisplay[field]

    Displays.update newDisplay._id,
      $set: setFields
    Displays.update oldDisplay._id,
      $set: swappedBy: newDisplay._id
    Router.go '/assign'