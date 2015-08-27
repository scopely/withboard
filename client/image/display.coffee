Template.DisplayImage.helpers
  attrs: -> if @display and @display.config
    src: @display.config.imageUrl
    style: if @display.config.fullScreen then 'position: absolute; top: 0; z-index: 50;'
    width: '100%'
