Template.DisplayIframe.helpers
  attrs: -> if @display and @display.config
    scale = @display.config.iframeScale ? 1.5

    src: @display.config.iframeUrl
    width: "#{100/scale}%"
    style: "-webkit-transform: scale(#{scale}); -webkit-transform-origin: 0 0;"
