var pairingSubs = {};

Meteor.methods({
  getPairingCode: function () {
    var code;
    while (!code || pairingSubs[code] !== undefined) {
      code = Math.random().toString(36).slice(2, 6);
    }

    console.log('New pairing code:', code);
    pairingSubs[code] = false;
    return code;
  },

  confirmPairing: function (code) {
    check(code, String);
    console.log(code, 'wants to finish pairing -', this.userId);

    if (pairingSubs[code] === undefined) {
      throw new Meteor.Error(400, 'Unknown or expired pairing session');
    } else if (pairingSubs[code] === false) {
      throw new Meteor.Error(400, 'Display is not ready to pair');
    } else if (!pairingSubs[code].adminId) {
      throw new Meteor.Error(401, 'Pairing has not been authorized yet');
    }

    var id = Accounts.createUser({username: 'display-' + code, profile: {type: 'display', ownerId: pairingSubs[code].adminId}});
    console.log('Display user', id, 'created from', code);

    if (pairingSubs[code].returnTo) {
      pairingSubs[code].returnTo.ready();
      pairingSubs[code].returnTo.stop();
      delete pairingSubs[code].returnTo;
    }
    pairingSubs[code].stop();

    var token = Accounts._generateStampedLoginToken();
    Accounts._insertLoginToken(id, token);

    var self = this;
    Meteor._noYieldsAllowed(function () {
      Accounts._setLoginToken(
        id,
        self.connection,
        Accounts._hashLoginToken(token.token)
      );
    });

    this.setUserId(id);
    return {id: id, token: token.token};
  },
});

Meteor.publish('pairing', function (code) {
  check(code, String);
  console.log('Got pairing subscription from', code);

  if (pairingSubs[code] === undefined) {
    return this.error(new Meteor.Error(400, 'Unknown or expired pairing code'));
  }
  pairingSubs[code] = this;

  this.onStop(function () {
    console.log(code, 'stopped caring about pairing');
    delete pairingSubs[code];
  });
});

Meteor.publish('pair', function (code) {
  check(code, String);
  console.log(this.userId || 'User', 'wants to pair to', code);

  if (pairingSubs[code] === undefined) {
    return this.error(new Meteor.Error(400, 'Unknown or expired pairing code'));
  } else if (pairingSubs[code] === false) {
    return this.error(new Meteor.Error(400, 'Display is not ready to pair'));
  } else {
    var sub = pairingSubs[code];
    sub.ready();
    pairingSubs[code].adminId = this.userId;
    pairingSubs[code].returnTo = this;
  }
});
