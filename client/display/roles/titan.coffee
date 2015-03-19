Template.DisplayTitan.helpers
  urlFor: (apps, url) ->
    app = apps.value[Meteor.userId()]
    url.value.replace '<api-key>', app
