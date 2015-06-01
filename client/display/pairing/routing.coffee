Router.route "displayPairing",
  path: "/display/pairing"
  template: "DisplayPairing"
  layoutTemplate: 'Display'
  data: -> if display = Displays.findOne()
    code: display._id
