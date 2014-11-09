Router.map(function () {
  this.route('displayDefault', { path: '/display',         template: 'DisplayDefault', layoutTemplate: 'Display' });
  this.route('displayPairing', { path: '/display/pairing', template: 'DisplayPairing', layoutTemplate: 'Display' });

  this.route('displayRooms',   { path: '/display/rooms',   template: 'DisplayRooms',   layoutTemplate: 'Display', data: function () {
    return { cals: State.findOne({key: 'calendars'}) };
  }});
  this.route('displayRecruiting', { path: '/display/recruiting', template: 'DisplayRecruiting', layoutTemplate: 'Display', data: function () {
    return State.findOne({key: 'recruiting-list'});
  }});

  this.route('displayRoles',   { path: '/display/:role',   template: 'DisplayDefault', layoutTemplate: 'Display' });
});

var timeDep = new Deps.Dependency();
var time = moment();

Meteor.setInterval(function () {
  time = moment();
  timeDep.changed();
}, 1000);

Template.Display.helpers({
  clock: function (timeFormat) {
    timeDep.depend();
    return time.format(timeFormat);
  },

  label: function () {
    var user = Meteor.user();

    if (!user)
      return 'Inactive';
    if (user.profile.type != 'display' && user.profile.name)
      return user.profile.name.split(' ')[0];
    if (user.profile.title || user.profile.role)
      return user.profile.title || user.profile.role;
    if (user.username)
      return user.username.slice(8);
    return Config.findOne({key: 'org'}).value;
  },

  clan: function () {
    var clan = State.findOne({ key: 'daily-clan' });
    var clans = Config.findOne({ key: 'clans' });
    console.log(clan, clans);
    if (!clan || !clans) return {};

    return clans.value.filter(function (c) {
      return c.key == clan.value;
    })[0];
  },
});

Template.Display.rendered = function () {
  Meteor.subscribe('state');
  Meteor.subscribe('config');

  Tracker.autorun(function () {
    var user = Meteor.user();

    if (!Meteor.userId()) return Router.go('displayPairing');
    if (!user) return;
    if (user.profile.type != 'display') return;

    if (user.profile.role)
      Router.go('/display' + (user.profile.role == 'default' ? '' : '/' + user.profile.role));
  });

  // Support chromecast receivers
  if (window.cast && cast.receiver) {
    window.castReceiverManager = cast.receiver.CastReceiverManager.getInstance();
    window.castReceiverManager.start();
  }
}

Template.DisplayPairing.rendered = function () {
  if (Meteor.userId()) {
    Router.go('displayDefault');
  }

  Meteor.call('getPairingCode', function (err, code) {
    Session.set('pairingCode', code);

    console.log('Waiting for pairing to begin for', code);
    Meteor.subscribe('pairing', code, {
      onReady: function () {
        console.log('Finalizing pairing');

        Accounts.callLoginMethod({
          methodName: 'confirmPairing',
          methodArguments: [code],
          userCallback: function (err) {
            if (err) {
              console.log('Login error:', err);
            } else {
              console.log('Login looks good!');
              Router.go('displayDefault');
            }
          }
        });
      },
      onError: function (err) {
        console.log('Pairing subscription error:', err);

        if (err.error == 400) {
          // probably just an old code that the server doesn't acknowledge
          Router.go('display');
        }
      },
    });
  });
};

Template.DisplayPairing.helpers({
  code: function () {
    return Session.get('pairingCode');
  },
});

Template.DisplayRooms.helpers({
  values: function (cals) {
    if (!cals) return [];
    return _.sortBy(Object.keys(cals).map(function (calId) {
      cals[calId].id = calId;
      return cals[calId];
    }), 'summary');
  },

  isImportant: function (calId) {
    return Config.findOne({key: 'important-cals'}).value.indexOf(calId) > -1;
  },
  isntImportant: function (calId) {
    return Config.findOne({key: 'important-cals'}).value.indexOf(calId) == -1;
  },
});

Template.DisplayRoom.helpers({
  firstName: function (user) {
    return (user && user.displayName) ? user.displayName.split(' ')[0] : 'n/a';
  },

  upcoming: function (events) {
    return _.sortBy(events, function (event) {
      return +moment(event.start.dateTime);
    }).map(function (event) {
      return event;
    });
  },

  format: function (date) {
    return moment(date.dateTime).fromNow();
  },

  getState: function (startTime, endTime) {
    var start = moment(startTime.dateTime),
        end   = moment(  endTime.dateTime);

    if (start.isAfter())
      return 'future';
    if (end.isBefore())
      return 'past';
    return 'present';
  },

  explain: function (startTime, endTime) {
    var start = moment(startTime.dateTime),
        end   = moment(  endTime.dateTime);

    if (start.isAfter())
      return 'starts ' + start.fromNow();
    if (end.isBefore())
      return 'ended';
    return 'ends ' + end.fromNow();
  },

  hasPassed: function (date) {
    return moment(date.dateTime).isBefore();
  },

  scheduleState: function (items) {
    var relevant = items.filter(function (item) {
      return moment(item.end.dateTime).isAfter();
    });

    return relevant.length ? 'booked' : 'empty';
  },

});

Template.DisplayRecruiting.rendered = function () {
  Session.set('position-highlight', 0);
  setInterval(function () {
    var next = Session.get('position-highlight');
    var list = State.findOne({ key: 'recruiting-list' }).value;

    do {
      next++;

      if (next >= list.length)
        next = 0;
    } while (!list[next].description);

    Session.set('position-highlight', next);
  }, 30 * 1000);
};

Template.DisplayRecruiting.helpers({
  withClass: function (list) {
    return list.map(function (position, idx) {
      var active = Session.get('position-highlight') == idx;
      position.cssClass = active ? 'active' : '';
      return position;
    });
  },

  activePosition: function () {
    return Template.currentData().value[Session.get('position-highlight')];
  },

  formatted: function (text) {
    return text.split('<').join('&lt;').split('\n').join('<br>');
  }
});
