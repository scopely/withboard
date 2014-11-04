Meteor.methods({
  setupProvider: function () {
    console.log('Provider connected');
    Config.upsert({key: 'has-provider'}, {key: 'has-provider', value: true});
    State.upsert({ key: 'has-provider'}, {key: 'has-provider', value: true});
    return 'cool';
  },

  setConfig: function (key, value) {
    console.log('Provider set config', key, 'to', value);
    return Config.upsert({key: key}, {key: key, value: value, source: 'provider'});
  },
  setState: function (key, value) {
    console.log('Provider set state', key, 'to', value);
    return State.upsert({key: key}, {key: key, value: value, source: 'provider'});
  },
});

Meteor.publish('config', function () {
  return Config.find();
});
Meteor.publish('state', function () {
  return State.find();
});
