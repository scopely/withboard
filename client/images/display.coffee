images = new ReactiveVar []
image = new ReactiveVar
fullScreenToggle = new ReactiveVar false
intervalSecs = new ReactiveVar 30

Template.DisplayImages.helpers
  wrapAttrs: ->
    css = 'z-index: ' + (if fullScreenToggle.get() then 50 else -50) + ';'
    css += 'padding-top: 100px;' unless fullScreenToggle.get()
    css += 'position: absolute; top: 0; bottom: 0; background-color: #000;'
    css += 'width: 100%; display: flex;'
    style: css

  attrs: -> if img = image.get()
    css = 'background-image: url("' + img.url + '"); background-size: contain;'
    css += 'background-repeat: no-repeat; background-position: center;'
    css += 'flex: 1'
    style: css

Template.DisplayImages.onRendered ->
  Session.set 'label', false

  nextImage = -> if nextObj = Random.choice images.get()
    preload = document.createElement 'img'
    preload.src = nextObj.url
    preload.onload = (e) ->
      image.set nextObj

  @autorun -> if ({display} = Template.currentData()) and display
    {imageSet, imageInterval, fullScreen} = display.config
    intervalSecs.set imageInterval
    fullScreenToggle.set fullScreen

    if imageMap = State.findOne(key: 'images')?.value
      images.set imageMap[imageSet] ? []
      nextImage() unless image.get()

  interval = null
  @autorun ->
    console.log 'interval:', intervalSecs.get()
    Meteor.clearInterval interval if interval
    interval = Meteor.setInterval nextImage, intervalSecs.get() * 1000
