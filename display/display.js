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
  });

  Template.DisplayUnassigned.rendered = function () {
    console.log('User ID:', Meteor.userId());

    if (!Meteor.userId()) {
      Router.go('/display/pairing');
    }
  };

  Template.DisplayPairing.rendered = function () {
    if (Meteor.userId()) {
      Router.go('/display');
    }

    Meteor.call('getPairingCode', function (err, code) {
      Session.set('pairingCode', code);

      console.log('Waiting for pairing to begin for', code);
      Meteor.subscribe('pairing', code, function () {
        console.log('Finalizing pairing');

        Accounts.callLoginMethod({methodName: 'confirmPairing', methodArguments: [code]});
      });
    });
  };

  Template.DisplayPairing.helpers({
    code: function () {
      return Session.get('pairingCode');
    },
  });
}
