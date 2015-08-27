timer = new Chronos.Timer 60 * 1000
timer.start()

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

  avatar: (size) ->
    (if size >= 128 then @imgBig else @imgThumb) or Gravatar.imageUrl @email,
      secure: true
      size: size || 128
      d: 'retro'
