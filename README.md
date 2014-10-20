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
