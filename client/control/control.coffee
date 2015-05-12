Template.ControlHome.events
  'click #pair': ->
    code = $('#tvid').val()
    console.log 'Attempting to pair to display', code

    Meteor.subscribe 'pair', code, ->
      console.log 'Pairing might have worked'
