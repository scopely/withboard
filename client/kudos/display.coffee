ddp = new ReactiveVar
collections = new ReactiveVar

timer = new Chronos.Timer 60 * 1000
timer.start()

Template.DisplayKudos.helpers
  topPost: -> if c = collections.get()
    c.Posts.findOne {}, sort: date: -1
  oldPosts: -> if c = collections.get()
    c.Posts.find {}, skip: 1, sort: date: -1

Template.Kudo.helpers
  postImage: -> if c = collections.get()
    c.PostImages.findOne @image if @image
  person: (_id) -> if c = collections.get()
    c.People.findOne _id ? @
  people: (_ids) -> if c = collections.get()
    _ids.map (_id) -> c.People.findOne _id ? @

  timeAgo: (time) ->
    timer.time.get()
    moment(time).fromNow()

  first: (name) ->
    name and name.split(' ')[0]

Template.DisplayKudos.onRendered ->
  @autorun => if url = Config.findOne(key: 'kudos-url')
    unless connection = ddp.get()
      ddp.set(connection = DDP.connect(url.value))
      collections.set
        People     : new Mongo.Collection 'people',      {connection}
        Posts      : new Mongo.Collection 'posts',       {connection}
        PostImages : new Mongo.Collection 'post-images', {connection}

    connection.subscribe 'kudos feed'
