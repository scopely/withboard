Meteor.publish('displays', function () {
  if (this.userId && Meteor.users.findOne(this.userId).profile.type != 'display')
    return Meteor.users.find({'profile.type': 'display'}, {fields: {profile: 1}});
  else
    return [];
});
