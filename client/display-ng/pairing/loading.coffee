Template.DisplayNgPairing.helpers
  code: ->
    # if we are waiting to pair,
    # show the pairing code
    if display = Displays.findOne()
      unless display.token
        return display._id
