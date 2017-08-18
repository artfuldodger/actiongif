# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('body').on 'click', (e) ->
    console.log "creating a sticker at #{e.clientX}, #{e.clientY}"
    App.stickers.stick(e.clientX, e.clientY)
