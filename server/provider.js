Meteor.methods({
  setupProvider: function (key) {
    var realKey = Config.findOne({ key: 'provider-key' });
    if (!realKey || realKey.value != key)
      throw new Meteor.Error(401, 'Invalid provider key');
    else
      console.log('Provider connected');

    var userId, user = Meteor.users.findOne({ provider: true });
    if (user)
      userId = user._id;
    else
      userId = Meteor.users.insert({ provider: true, profile: {} });
    this.setUserId(userId);

    return true;
  },

  setConfig: function (key, value) {
    if (!this.userId) throw new Meteor.Error(401, 'Not enough privledges');
    if (!Meteor.users.findOne(this.userId).provider)
      throw new Meteor.Error(401, 'Not provider');

    console.log('Provider set config', key, 'to', value);
    return Config.upsert({key: key}, {key: key, value: value, source: 'provider'});
  },

  setState: function (key, value) {
    if (!this.userId) throw new Meteor.Error(401, 'Not enough privledges');
    if (!Meteor.users.findOne(this.userId).provider)
      throw new Meteor.Error(401, 'Not provider');

    console.log('Provider set state', key, 'to', value);
    return State.upsert({key: key}, {key: key, value: value, source: 'provider'});
  },
});

Meteor.publish('config', function () {
  return this.userId ? Config.find() : [];
});
Meteor.publish('state', function () {
  return this.userId ? State.find() : [];
});
