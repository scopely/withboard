Template.DisplayRecruiting.rendered = () ->
  Session.set 'position-highlight', 0
  setInterval ->
    next = Session.get 'position-highlight'
    list = State.findOne(key: 'recruiting-list').value

    loop
      next += 1
      next = 0 if next >= list.length
      break if list[next].description

    Session.set 'position-highlight', next
  , 30 * 1000

Template.DisplayRecruiting.helpers
  withClass: (list) ->
    list.map (position, idx) ->
      active = Session.get('position-highlight') == idx
      position.cssClass = if active then 'active' else ''
      position

  activePosition: ->
    Template.currentData().value[Session.get('position-highlight')]

  formatted: (text) ->
    text.split('<').join('&lt;').split('\n').join('<br>')
