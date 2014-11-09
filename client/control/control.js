Router.map(function () {
  this.route('control', { path: '/control', template: 'ControlHome', layoutTemplate: 'ControlLayout' });
  this.route('displays', { path: '/control/displays', template: 'Displays', layoutTemplate: 'ControlLayout', data: function () {
    return {
      displays: Meteor.users.find({'profile.type': 'display'}),
      users: Meteor.users.find({'profile.type': {$ne: 'display'}}),
    };
  }});
  this.route('settings', { path: '/control/settings', template: 'Configs', layoutTemplate: 'ControlLayout', data: function () {
    return { configs: Config.find() };
  }});
  this.route('states', { path: '/control/states', template: 'States', layoutTemplate: 'ControlLayout', data: function () {
    return { states: State.find() };
  }});

  this.route('index',   { path: '/', action: function () {
    this.redirect('/control');
  }});
});

Template.ControlHome.events({
  'click #pair': function () {
    var code = $('#tvid').val();
    console.log('Attempting to pair to display', code);

    Meteor.subscribe('pair', code, function () {
      console.log('Pairing might have worked');
    });
  },
});

Template.DisplayCard.events({
  'submit form': function (event) {
    Meteor.call('updateDisplay', event.target._id.value, {
      name:  event.target.name.value,
      title: event.target.title.value,
      role:  event.target.role.value,
    });
    return false;
  },
});

Template.DisplayCard.helpers({
  roles: function () {
    return Roles.map(function (role) {
      return { role: role };
    });
  },
});

Template.States.events({
  'submit .form-update': function (event) {
    State.update(event.target._id.value, {
      $set: { value: JSON.parse(event.target.value.value) }
    });
    return false;
  },

  'submit .form-create': function (event) {
    State.insert({
      key: event.target.key.value,
      value: JSON.parse(event.target.value.value),
    });

    event.target.key.value = '';
    event.target.value.value = '';
    return false;
  },
});

Template.Configs.events({
  'submit .form-update': function (event) {
    Config.update(event.target._id.value, {
      $set: { value: JSON.parse(event.target.value.value) }
    });
    return false;
  },

  'submit .form-create': function (event) {
    Config.insert({
      key: event.target.key.value,
      value: JSON.parse(event.target.value.value),
    });

    event.target.key.value = '';
    event.target.value.value = '';
    return false;
  },
});

Template.KeyValueCard.helpers({
  json: function (data) {
    return JSON.stringify(data);
  },
});

Template.ControlLayout.helpers({
  collSize: function (coll) {
    return window[coll].find().count();
  },
});

Template.ControlLayout.rendered = function () {
  Meteor.subscribe('displays');
  Meteor.subscribe('config');
  Meteor.subscribe('state');

  var session = null;

  // CAST SENDING STARTS HERE
  console.log('Setting up Cast sender');
  var timer = setInterval(function () {
    if (chrome.cast && chrome.cast.isAvailable) {
      console.log('Setting up Cast');
      clearInterval(timer);
      initializeCastApi();
    }
  }, 50);

  function initializeCastApi() {
    var applicationID = '8ED67160';
    var sessionRequest = new chrome.cast.SessionRequest(applicationID);
    var apiConfig = new chrome.cast.ApiConfig(sessionRequest, sessionListener, receiverListener);

    chrome.cast.initialize(apiConfig, function () {
      console.log('cast: init success');
    }, function () {
      console.log('cast: error');
    });
  };

  function onSuccess(message) {
    console.log('cast:', message);
  }

  function onStopAppSuccess() {
    console.log('cast: session stopped');
  }

  function sessionListener(e) {
    console.log('cast: new session ID:', e.sessionId);
    session = e;

    if (session.media.length != 0) {
      console.log('cast: found', session.media.length, 'existing media sessions.');
    }
    session.addUpdateListener(sessionUpdateListener.bind(this));
  }

  function sessionUpdateListener(isAlive) {
    var message = isAlive ? 'session updated:' : 'session removed:';
    console.log('cast:', message, session.sessionId);

    if (!isAlive) {
      session = null;
    }
  }

  function receiverListener(e) {
    if (e === 'available') {
      console.log('cast: receiver found');
    } else {
      console.log('cast: receiver list empty');
    }
  }

  function launchApp() {
    console.log('cast: launching app...');
    chrome.cast.requestSession(onRequestSessionSuccess, function () {
      console.log('cast: launch error');
    });
  }

  function onRequestSessionSuccess(e) {
    console.log('cast: session success:', e.sessionId);
    session = e;
    session.addUpdateListener(sessionUpdateListener.bind(this));
    if (session.media.length != 0) {
      onMediaDiscovered('onRequestSession', session.media[0]);
    }
    session.addMediaListener(
      onMediaDiscovered.bind(this, 'addMediaListener'));
    session.addUpdateListener(sessionUpdateListener.bind(this));
  }

  function stopApp() {
    session.stop(onStopAppSuccess, onError);
  }
  // CAST SENDING ENDS HERE
};
