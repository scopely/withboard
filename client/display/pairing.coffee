Template.DisplayPairing.rendered = ->
  return Router.go 'displayDefault' if Meteor.userId()

  Meteor.call 'getPairingCode', (err, code) ->
    Session.set 'pairingCode', code

    console.log 'Waiting for pairing to begin for', code
    Meteor.subscribe 'pairing', code,
      onReady: ->
        console.log 'Finalizing pairing'

        Accounts.callLoginMethod
          methodName: 'confirmPairing'
          methodArguments: [code]
          userCallback: (err) ->
            if err
              console.log 'Login error:', err
            else
              console.log 'Login looks good!'
              Router.go 'displayDefault'

      onError: (err) ->
        console.log 'Pairing subscription error:', err

        if err.error == 400
          # probably just an old code that the server doesn't acknowledge
          Router.go 'display'

Template.DisplayPairing.helpers
  code: ->
    Session.get 'pairingCode'
