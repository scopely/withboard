Template.KeyValRow.helpers
  json: (data) -> JSON.stringify data
  shortJson: (data) ->
    if data.substr
      data.slice(0, 25) + if data.length > 25 then '...' else ''
    else if data.toFixed
      '' + data
    else
      json = JSON.stringify data
      json.slice(0, 25) + if json.length > 25 then '...' else ''
