var _timers = {};

function Timer(interval) {
  this.interval = interval || 1000;
  this.time = new ReactiveVar(0);
}

Timer.prototype.start = function() {
  if (this._timer) throw new Error('Trying to start Chronos.Timer but it is already running.');
  this._tick();
};

Timer.prototype._scheduleTick = function(interval) {
  this._timer = Meteor.setTimeout(this._tick.bind(this), interval);
}

Timer.prototype._tick = function() {
  this._scheduleTick(this.interval);
  this.time.set(new Date());
}

Timer.prototype._clearTimeout = function() {
  if (this._timer)
    Meteor.clearTimeout(this._timer);
  this._timer = null;
}

Timer.prototype.stop = function() {
  this._clearTimeout();
}

// Not reactive
Timer.prototype.isActive = function() {
  return !!this._timer;
}

// Reset the timer's interval
// Maintains start/stop state
Timer.prototype.setInterval = function(interval) {
  this.interval = interval;

  // If we're running, smoothly change timer
  if (this.time.curVal && this.isActive()) {
    this._clearTimeout();
    var passedTime = (+new Date) - (+this.time.curVal)

    // Don't want negatives
    var nextTick = Math.max(interval - passedTime, 0);
    this._scheduleTick(nextTick);
  }
}

// Shorthand to simply depend on the timer
Timer.prototype.dep = function() {
  this.time.get();
}


function liveUpdate(interval) {
  // get current reactive context
  var comp = Tracker.currentComputation;
  if (!comp)
    return; // no nothing when used outside a reactive context

  // only create one timer per reactive context to prevent stacking of timers
  var cid =  comp && comp._id;
  if (!_timers[cid]) {
    var timer = new Timer(interval);
    _timers[cid] = timer;

    // add destroy method that stops the timer and removes itself from the list
    timer.destroy = function() {
      timer.stop();
      delete _timers[cid];
    };

    timer.start();
  }

  // make sure to stop and delete the attached timer when the computation is stopped
  comp.onInvalidate(function() {
    //console.log('onInvalidated',comp);
    if (comp.stopped && _timers[cid]) {
      //console.log('computation stopped');
      _timers[cid].destroy();
    }
  });

  _timers[cid].time.dep.depend(comp); // make dependent on time

  //console.log(_timers);
  return _timers[cid];
}

// wrapper for moment.js
function liveMoment(/* arguments */) {
  // only reactively re-run liveMoment when moment is available
  if (!moment) return;

  liveUpdate();
  return moment.apply(null, arguments);
}

function currentTime(interval) {
  liveUpdate(interval);
  return new Date();
}

// export global
Chronos = {

  // a simple reactive timer
  // usage: var timer = new Timer();
  // get current time: timer.time.get();
  Timer : Timer,

  // handy util func for making reactive contexts live updating in time
  // usage: simply call Chronos.liveUpdate() in your helper to make it execute
  // every interval
  liveUpdate : liveUpdate,

  // wrapper for moment.js
  // example usage: Chronos.liveMoment(someTimestamp).fromNow();
  liveMoment: liveMoment,

  // get the current time, reactively
  currentTime: currentTime,

  // for debugging and testing
  _timers : _timers
};
