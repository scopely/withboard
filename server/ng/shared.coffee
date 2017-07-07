Meteor.publish '/screens/shared', (token) ->
  [
    Modules.find {}, # {'sharing.on': true},
      fields:
        name: 1
    Views.find {}, # {'sharing.on': true},
      fields:
        name: 1
        module: 1
    Screens.find {}, # {'sharing.on': true},
      fields:
        name: 1
        view: 1
  ]