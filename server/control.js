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
    if (!this.userId) return null;

    var display = Meteor.users.findOne(_id);
    if (!display || !display.profile || display.profile.type != 'display') return false;

    var obj = {};
    Object.keys(fields).forEach(function (key) {
      obj['profile.' + key] = fields[key];
    });

    Meteor.users.update({ _id: _id }, { $set: obj });
  },
});
