update = ->
  docId = Config.findOne(key: 'onsites-sheet')?.value
  userId = Config.findOne(key: 'google-user-id')?.value
  return unless docId and userId

  raw = GoogleApi.get "spreadsheets/export?id=#{docId}&exportFormat=csv",
    host: 'https://docs.google.com'
    user: Meteor.users.findOne(userId)
  {data, errors} = Baby.parse raw

  today = '10/7/2015'  # moment().format 'M/D/YYYYY'

  guests = []
  guest = null
  for [date, visitor, dept, host, time, room] in data.slice(1)
    if date is today and visitor
      guest = {date, visitor, dept, room, schedule: []}
      guests.push guest

    if time and guest
      [from, to] = time.match(/[0-9:]+ [AP]M/g)
      fromMoment = moment [guest.date, from].join(' '), 'M/D/YYYY h:mm am'
      toMoment = moment [guest.date, to].join(' '), 'M/D/YYYY h:mm am'

      guest.schedule.push
        from: fromMoment.toDate()
        to: toMoment.toDate()
        host: host

  State.upsert {key: 'onsites'},
    $set: value: guests

  console.log 'Fetched', guests.length, 'onsites'

Meteor.startup -> Meteor.defer update
Meteor.setInterval update, 15 * 60 * 1000 # 15 minutes
