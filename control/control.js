if (Meteor.isClient) {
  Template.Control.events({
    'click #pair': function () {
      var code = $('#tvid').val();
      console.log('Attempting to pair to display', code);

      Meteor.subscribe('pair', code, function () {
        console.log('Pairing might have worked');
      });
    },
  });

  Template.Control.rendered = function () {
    Meteor.subscribe('displays');

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

} else if (Meteor.isServer) {
  Meteor.publish('displays', function () {
    if (this.userId && Meteor.users.findOne(this.userId).profile.type != 'display')
      return Meteor.users.find({'profile.type': 'display'}, {fields: {profile: 1}});
    else
      return [];
  });

}
