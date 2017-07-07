window.ScreenSizeDep = new Tracker.Dependency
{screen} = window # From user-agent

lastSize = [screen.width, screen.height]
$(document.body).resize ->
  # stuff