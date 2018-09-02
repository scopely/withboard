Template.ManageDisplay.helpers
  objectPair: (obj) ->
    Object.keys(obj).map (k) ->
      key: k
      value: obj[k]
