Template.DisplayIframe.helpers
  attrs: -> if @display and @display.config
    scale = @display.config.iframeScale ? 1
    css = [
      "-webkit-transform: scale(#{scale})"
      '-webkit-transform-origin: 0 0'
      @display.config.iframeCss
    ]

    src: @display.config.iframeUrl
    width: "#{100/scale}%"
    height: "1000px"
    style: css.join ';'

Template.DisplayIframe.onRendered ->
  interval = null
  refresh = ->
    console.log 'refreshing'
    iframe = @$('iframe')[0]
    iframe.src = iframe.src

  @autorun ->
    Meteor.clearInterval interval if interval

    interval = if display = Template.currentData().display
      if display and (interval = display.config.iframeRefresh) > 0
        Meteor.setInterval refresh, interval * 60 * 1000
