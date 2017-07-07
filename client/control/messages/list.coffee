Template.MessageList.helpers
  ago: ->
    moment(@enableAt).calendar()

  messageClass: ->
    now = try Chronos.liveMoment()
    catch then moment()

    if now.isBefore(@expireAt)
      'message-active'

Template.MessageList.events
  'click .secondary-content': ->
    if confirm 'Really delete?'
      Messages.remove @_id
