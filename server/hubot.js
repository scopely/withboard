Router.map(function () {
  this.route('command', {
    where: 'server',
    action: function () {
      if (this.request.body.announce) {
        State.upsert({ key: 'announce' }, { $set: {
          value: {
            text: this.request.body.announce,
            active: true,
            expires: +moment() + (5 * 60 * 1000),
          }
        }});
        this.response.writeHead(200, { 'Content-Type': 'text/plain' });
        this.response.write('Okay, done');
        this.response.end();
      } else {
        this.response.writeHead(200, { 'Content-Type': 'text/plain' });
        this.response.write('Huh?');
        this.response.end();
      }
    },
  });

  this.route('now-playing', {
    where: 'server',
    action: function () {
      this.response.writeHead(200, { 'Content-Type': 'application/json' });
      this.response.write(JSON.stringify(State.findOne({ key: 'now-playing' }).value));
      this.response.end();
    },
  });
});
