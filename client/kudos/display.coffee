window.ddp = new ReactiveVar
window.collections = new ReactiveVar

timer = new Chronos.Timer 60 * 1000
timer.start()

Template.DisplayKudos.helpers
  topPost: -> if c = collections.get()
    c.Posts.findOne {}, sort: date: -1
  oldPosts: -> if c = collections.get()
    c.Posts.find {}, skip: 1, sort: date: -1

Template.DisplayKudos.onRendered ->
  @autorun => if url = Config.findOne(key: 'kudos-url')
    unless connection = ddp.get()
      ddp.set(connection = DDP.connect(url.value))
      collections.set
        People     : new Mongo.Collection 'people',      {connection}
        Posts      : new Mongo.Collection 'posts',       {connection}
        PostImages : new Mongo.Collection 'post-images', {connection}

    connection.subscribe 'kudos feed'
