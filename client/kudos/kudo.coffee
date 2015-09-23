timer = new Chronos.Timer 60 * 1000
timer.start()

getEntity = (c, entity) ->
  [type, id] = entity.split ':'
  if type isnt 'dog'
    id = type
    type = 'person'

  person = c.People.findOne id
  if type is 'person'
    return person
  else if type is 'dog'
    return person?.dog

Template.Kudo.helpers
  postImage: -> if c = collections.get()
    c.PostImages.findOne @image if @image
  person: (_id) -> if c = collections.get()
    getEntity c, _id ? @
  people: (_ids) -> if c = collections.get()
    _ids.map (_id) -> getEntity c, _id ? @

  timeAgo: (time) ->
    timer.time.get()
    moment(time).fromNow()

  first: (name) ->
    name?.split(' ')[0]
