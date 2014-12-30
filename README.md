Withboard
=========
Copyright Scopely, Inc. 2014.  
Distributed under the Apache 2.0 License. See `LICENSE.md` for details.

Overview
--------
A dynamic digital signage application, intended for dashboards, infoboards,
display boards, or anything else that could go on TVs around an office or
campus. Withboard has first-class Chromecast support. Chromecasts were chosen
because of simplicity and the inexpensive setup costs of $35 per TV (or free if
you already have some). Raspberry Pis also work, at the cost of performance.
Any combination of hardware can be used within one system.

Withboard runs on the [Meteor](http://meteor.com) platform. Meteor is
NodeJS-based and uses MongoDB for data storage. The Meteor feature-set appeals
to Withboard's design, and the end result [should be] a very straightforward
application.

Initial setup
-------------
Withboard isn't polished enough to be usable out of the box yet. This will be
improved going forward, but if you're still interested in messing with it as is,
setup steps are below. Be warned that you will need to build your own data sources.
Check back later if you'd like to just use prebuilt providers :)

### Deployment
You'll need to install the [Meteor](http://meteor.com) platform if you haven't already.

1. Deploy your clone to meteor.com under a unique name. I took "withboard", sorry!
  * `meteor deploy xyz.meteor.com`
2. Gain access to the [Cast SDK Console](https://cast.google.com/publish/)
3. Create a new Cast application.
  * Your URL will be `https://xyz.meteor.com/display` with your unique subdomain.
  * You can list a Chrome sender app URL: `https://xyz.meteor.com/control`
4. Copy your new 8-character app ID from the Cast SDK Console
5. Drop your app ID into the top of `client/control/sender.coffee`
6. Deploy your app again

You'll now be able to cast your Withboard instance from the meteor app.
Pairing a device should work without issue. Now you just have to build out the
views and get your data in the system!

Flexibility
-----------
The essence of Withboard is a data store (Mongo-backed for this implementation)
which any display component can subscribe to, and which a simple job or process
can push to. External services can also fetch and manage the state, allowing
deeper integration with internal tools and apps.

Of course any component can also create its own Mongo collections if it wants
isolated data storage. Room schedules and slide rotations will probably work
in this manner.

Deployment
----------
Heroku- and EC2-based deployments will be supported. Typical EC2 deployments
will include an ELB for SSL termination, though you can totally just terminate
SSL yourself on the instance.

SSL is _required_ for production Chromecast support. If you don't want SSL
hassle, deploy on Heroku for free.

As this is a Meteor app, you can also easily deploy to Meteor's free hosting:

    $ meteor deploy my-withboard.meteor.com

Running locally
---------------
1. Grab [Meteor](http://meteor.com) if you don't have it yet
2. Clone this repo
3. Run `meteor` in your clone
