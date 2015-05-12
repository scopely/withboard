Template.DisplayPair.events
  'click a': ->
    Meteor.subscribe 'pair', $('#pairCode').val(), ->
      $('#pairCode').val('')
    false
