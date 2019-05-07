Meteor.publish '/messages/history', -> if @userId then [
  Messages.find {},
    sort:
      createdAt: -1
    limit: 25
] else throw Meteor.Error 'logged-out'
