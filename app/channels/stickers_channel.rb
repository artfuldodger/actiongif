class StickersChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def stick(coordinates)
    Services::StickerCreation.new(
      x: coordinates['x'],
      y: coordinates['y']
    ).create
  end
end
