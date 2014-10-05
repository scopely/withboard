Router.map(function () {
  this.route('display', { path: '/display', template: 'DisplayUnassigned', layoutTemplate: 'Display' });
  this.route('displayPairing', { path: '/display/pairing', template: 'DisplayPairing', layoutTemplate: 'Display' });
});

if (Meteor.isClient) {
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
      if (user.profile.type != 'display')
        return user.profile.name.split(' ')[0];
      return user.profile.label || user.profile.role || user.username.slice(8);
    }
  });

  Template.DisplayUnassigned.rendered = function () {
    Tracker.autorun(function () {
      var user = Meteor.user();

      if (!Meteor.userId()) return Router.go('displayPairing');
      if (!user) return;
      if (user.profile.type != 'display') return;
      if (user.profile.role) Router.go('/display/' + user.profile.role);
    });
  };

  Template.DisplayPairing.rendered = function () {
    if (Meteor.userId()) {
      Router.go('display');
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
                Router.go('display');
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
}
