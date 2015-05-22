window.textareaAutoResize = ($textarea) ->
  hiddenDiv = $('<div class="hiddendiv common"></div>')
  $('body').append hiddenDiv

  # Set fontsize of hiddenDiv
  fontSize = $textarea.css 'font-size'
  hiddenDiv.css 'font-size', fontSize if fontSize

  hiddenDiv.text "#{$textarea.val()}\n"
  content = hiddenDiv.html().replace(/\n/g, '<br>')
  hiddenDiv.html content

  # When textarea is hidden, width goes crazy.
  # Approximate with half of window size

  if $textarea.is ':visible'
    hiddenDiv.css 'width', $textarea.width()
  else
    hiddenDiv.css 'width', $(window).width() / 2.7

  $textarea.css 'height', hiddenDiv.height()

  hiddenDiv.remove()
