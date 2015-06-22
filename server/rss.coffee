Meteor.methods getRss: (display) ->
  check display, String
  if url = Displays.findOne(display).config.rss
    xml2js.parseStringSync HTTP.get(url).content,
      trim: true
      explicitArray: false
    .rss.channel.item
    # also rss.channel.title
  else []
