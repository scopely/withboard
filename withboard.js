if (Meteor.isClient) {
  // do client things

} else if (Meteor.isServer) {
  Meteor.startup(function () {
    // do server things
    
  });
}
