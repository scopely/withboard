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
  };

} else if (Meteor.isServer) {
  Meteor.publish('displays', function () {
    if (this.userId && Meteor.users.findOne(this.userId).profile.type != 'display')
      return Meteor.users.find({'profile.type': 'display'}, {fields: {profile: 1}});
    else
      return [];
  });

}
