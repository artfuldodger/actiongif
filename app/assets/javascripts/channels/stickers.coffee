App.stickers = App.cable.subscriptions.create "StickersChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log "Received: ", data
    $('body').append(data.sticker)

  stick: (x, y) ->
    @perform 'stick', x: x, y: y
