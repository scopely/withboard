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
}
