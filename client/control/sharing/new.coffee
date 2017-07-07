Template.SharingList.events
  'click .new': (evt) ->
    evt.preventDefault()

    Shares.insert
      _id: prompt 'URL Slug (leave blank for random ID)'
      owner: Meteor.userId()
      title: prompt 'Display name'
      sharing: 'myself'
    , (err, id) ->
      if err
        alert "Couldn't create share.\r\n\r\n" + err
      else
        Router.go 'ManageSharing', {id}

###
Shares.attachSchema new SimpleSchema
  owner     : type: String
  title     : type: String, optional: true
  entries   : type: [Context]

  sharing   : type: String, allowedValues: ['myself', 'unlisted', 'domain', 'public']
  token     : type: String
###