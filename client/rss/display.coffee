articles = new ReactiveVar []
article = new ReactiveVar
leftImage = new ReactiveVar false

Template.DisplayRss.helpers
  article: -> article.get()
  leftImage: -> leftImage.get()

  image: -> @['media:content'].$.url
  snippit: -> @description.match(/<blockquote>(.+)<\/blockquote>/)[1]
  date: -> moment(@pubDate).format 'LLL'

Template.DisplayRss.onRendered ->
  updateFeed = ->
    {_id} = Template.currentData().display
    Meteor.call 'getRss', _id, (err, newList) ->
      if err
        console.log 'RSS update error:', err
      else
        articles.set newList.filter (item) -> item['media:content']
        article.set articles.get()[0]
        console.log 'Got', articles.get().length, 'articles'

  nextArticle = ->
    article.set Random.choice articles.get()
    leftImage.set(not leftImage.get())

  interval = null
  @autorun -> if ({display} = Template.currentData()) and display
    updateFeed()
    Meteor.setInterval updateFeed, 60 * 60 * 1000

    console.log display.config
    Meteor.clearInterval interval if interval
    interval = if rssInterval = display.config.rssInterval
      console.log 'interval', rssInterval
      Meteor.setInterval nextArticle, rssInterval * 1000
