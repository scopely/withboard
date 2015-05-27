Template.DisplayPairing.onRendered ->
  return Router.go 'displayDefault' if Meteor.userId()

  Meteor.call 'getPairingCode', (err, code) ->
    Session.set 'pairingCode', code

    $('#qr-pair').qrcode
      text: Meteor.absoluteUrl "control/pair/#{code}"
      size: 400
      #ecLevel: 'H'
      fill: "#00557f"
      #background: "#fafafa"
      radius: 0.3

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

        if err.error is 400
          # probably just an old code that the server doesn't acknowledge
          Router.go 'display'

Template.DisplayPairing.helpers
  code: -> Session.get 'pairingCode'
