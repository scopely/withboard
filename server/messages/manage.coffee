Meteor.publish '/messages/history', ->
  Messages.find {},
    sort:
      createdAt: -1
    limit: 25