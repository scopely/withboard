root.fetchGSheet = ({userId, sheetId, tabId}) ->
  unless userId and sheetId
    throw new Meteor.Error 'missing-config', "Can't fetch Google Sheet without config"

  params =
    id: sheetId
    format: 'csv'
  params.gid = tabId if tabId

  raw = GoogleApi.get 'spreadsheets/export',
    params: params
    host: 'https://docs.google.com'
    user: Meteor.users.findOne(userId)
  {data, errors} = Baby.parse raw

  return data
