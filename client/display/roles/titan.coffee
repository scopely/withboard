Template.DisplayTitan.rendered = ->
  Session.set 'app-highlight', -1

  handler = ->
    next = Session.get 'app-highlight'
    list = Config.findOne(key: 'titan-apps').value[Meteor.userId()]

    next += 1
    next = 0 if next >= list.length
    app = list[next]

    url = Config.findOne(key: 'titan-url').value
    origin = url.split('/').slice(0,3).join('/')

    iframe = document.getElementById('titan')
    iframe.contentWindow.postMessage dash: app.key, origin

    # Casts are really slow at this.
    # Until Portal emits app info to us, just delay our own data.
    setTimeout ->
      Session.set 'label', app.name
    , 2000

    Session.set 'app-highlight', next

  setTimeout handler, 10 * 1000
  setInterval handler, 60 * 1000
