window.ddp = new ReactiveVar
window.collections = new ReactiveVar

Template.DisplayKudos.helpers
  topPost: -> if c = collections.get()
    c.Posts.findOne {}, sort: date: -1
  oldPosts: -> if c = collections.get()
    c.Posts.find {}, skip: 1, sort: date: -1

  iframeAttrs: -> if @display and @display.config
    scale = @display.config.iframeScale ? 1

    src: @display.config.iframeUrl
    width: "#{100/scale}%"
    height: "1000px"
    style: "-webkit-transform: scale(#{scale}); -webkit-transform-origin: 0 0; border: 0; margin-top: -170px;"

Template.DisplayKudos.onRendered ->
  interval = null
  refresh = ->
    console.log 'refreshing'
    iframe = @$('iframe')[0]
    iframe.src = iframe.src

  @autorun ->
    Meteor.clearInterval interval if interval
    interval = if display = Template.currentData().display
      console.log 'interval', display.config.iframeRefresh
      if display and interval = display.config.iframeRefresh
        Meteor.setInterval refresh, interval * 60 * 1000

Template.DisplayKudos.onRendered ->
  @autorun => if url = Config.findOne(key: 'kudos-url')
    unless connection = ddp.get()
      ddp.set(connection = DDP.connect(url.value))
      collections.set
        People     : new Mongo.Collection 'people',      {connection}
        Posts      : new Mongo.Collection 'posts',       {connection}
        PostImages : new Mongo.Collection 'post-images', {connection}

    connection.subscribe 'kudos feed'
