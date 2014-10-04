Router.map(function () {
  this.route('display', { path: '/display', template: 'Display' });
  this.route('control', { path: '/control', template: 'Control' });

  this.route('index',   { path: '/', action: function () {
    this.redirect('/control');
  }});
});

if (Meteor.isClient) {
  // do client things

} else if (Meteor.isServer) {
  Meteor.startup(function () {
    // do server things

  });
}
