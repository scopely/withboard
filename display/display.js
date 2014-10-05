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
}
