Router.map ->
  @route 'command',
    where: 'server'
    action: ->
      if @request.body.announce
        State.upsert { key: 'announce' }, $set:
          value:
            text: @request.body.announce
            active: true
            expires: +moment() + (5 * 60 * 1000)

        @response.writeHead 200, 'Content-Type': 'text/plain'
        @response.write 'Okay, done'
        @response.end();
      else
        @response.writeHead 200, 'Content-Type': 'text/plain'
        @response.write 'Huh?'
        @response.end()

  @route 'now-playing',
    where: 'server'
    action: ->
      @response.writeHead 200, 'Content-Type': 'application/json'
      @response.write JSON.stringify State.findOne(key: 'now-playing').value
      @response.end()
