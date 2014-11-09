Meteor.publish('displays', function () {
  if (this.userId && Meteor.users.findOne(this.userId).profile.type != 'display')
    return Meteor.users.find({'profile.type': 'display'}, {fields: {profile: 1}});
  else if (this.userId)
    return Meter.user();
  else
    return [];
});

Meteor.methods({
  updateDisplay: function (_id, fields) {
    var user = Meteor.users.findOne(this.userId);
    if (!user || user.profile.type == 'display') return null;
    console.log('DISPLAY UPDATE:', _id, fields);

    var display = Meteor.users.findOne(_id);
    if (!display || !display.profile) return false;

    var obj = {};
    Object.keys(fields).forEach(function (key) {
      obj['profile.' + key] = fields[key];
    });

    Meteor.users.update({ _id: _id }, { $set: obj });
  },
});

var isAdmin = function (userId, doc) {
  if (!userId) return false;
  var user = Meteor.users.findOne(userId);
  return !user.provider && user.profile && user.profile.type != 'display';
}

Meteor.startup(function () {
  Config.allow({ insert: isAdmin, update: isAdmin, remove: isAdmin });
  State.allow( { insert: isAdmin, update: isAdmin, remove: isAdmin });
});
