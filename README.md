Withboard
=========
Copyright Scopely, Inc. 2014-2017.
Distributed under the Apache 2.0 License. See `LICENSE.md` for details.

Overview
--------
A dynamic digital signage application, intended for dashboards, infoboards,
display boards, or anything else that could go on TVs around an office or
campus.

Withboard has first-class Chromecast support, but works on most Web devices:

* Chromecasts were chosen because of simplicity and the inexpensive setup costs
  of $35 per TV (or free if you already have some).
  A fleet of Chromecasts is like a herd of sheep - they don't do much
  by themselves, so you'll want to have a system on-site coordinating them
  and keeping them in line when they inevitably soft-fail.
  Also keep in mind network requirements like NOT isolating wireless clients,
  and a lack of WPA2 Enterprise support.
* Chromebits and other ChromeOS devices are ideal for heavier workloads
  and higher resolution (an i3 Chromebox can easily render 4K).
  ChromeOS devices are very stable and can boot right into Withboard,
  at the cost of a more-complicated provisioning procedure.
* Raspberry Pis and Intel Compute Sticks also work, at the cost of performance.
  I don't recommend using RPis but if you can configure a web browser to launch
  the `/display` URL at boot, you shouldn't have any problems.

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

1. Make a copy of `settings.dist.json` and fill in the settings.
    1. You'll want to create Google OAuth2 web credentials to allow admin panel access.
    2. Drop your company's email domain into `domain` to whitelist who can control the system.
    3. The `assets_s3_bucket` is used for any graphical assets, most importantly the default `logo.png` is loaded out of the path. Doesn't have to be S3 really.
    4. `organization_name` is the default TV title.
    5. You'll fill in `cast_application_id` later.
1. Deploy your clone somewhere. I use EC2, but it's up to you.
2. Gain access to the [Cast SDK Console](https://cast.google.com/publish/)
3. Create a new Cast application.
    * Your URL should look like `https://whatever.yourcompany.com/display`
    * You can list a Chrome sender app URL: `https://whatever.yourcompany.com/control`
4. Copy your new 8-character app ID from the Cast SDK Console
5. Drop your app ID into your copy of `settings.json`
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

Running locally
---------------
1. Grab [Meteor](http://meteor.com) if you don't have it yet
2. Clone this repo
3. Run `meteor` in your clone
1. Open [/display](http://localhost:3000/display) for a local display
1. Open [/control](http://localhost:3000/control) for the control panel
