# delete aged session data regularly

curate = ->
  olderThan = moment().subtract(1, 'month').toDate()
  count = ShareLog.remove
    endedAt: $lt: olderThan
  console.log 'Deleted', count, 'old ShareLogs.'

Meteor.setInterval curate, 60 * 60 * 1000
Meteor.startup curate
