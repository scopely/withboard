Template.DisplayTitan.helpers
  urlFor: (apps, url) ->
    myApps = apps.value[Meteor.userId()]
    app = myApps[0].key
    url.value.replace '<api-key>', app


Template.DisplayTitan.rendered = ->
  Session.set 'app-highlight', 0
  setInterval ->
    next = Session.get 'app-highlight'
    list = Config.findOne(key: 'titan-apps').value[Meteor.userId()]

    next += 1
    next = 0 if next >= list.length

    url = Config.findOne(key: 'titan-url').value
    origin = url.split('/').slice(0,3).join('/')

    app = list[next]
    iframe = document.getElementById('titan')

    iframe.contentWindow.postMessage apiKey: app.key, origin

    # Casts are really slow at this.
    # Until Portal emits app info to us, just delay our own data.
    setTimeout ->
      Session.set 'label', app.name
    , 2000

    Session.set 'app-highlight', next
  , 30 * 1000
