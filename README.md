# What is this?

This is a sample Rails 5.1 app to show the usage of Action Cable.
The rest of the readme describes how it was made.

# Intro

What's a WebSocket? https://en.wikipedia.org/wiki/WebSocket

What's Action Cable? http://edgeguides.rubyonrails.org/action_cable_overview.html

# Okay, let's generate a rails 5 app

```
cd ~/oss/rails # path to where you've checked out the rails repo
railties/exe/rails new ~/play/actiongif
```

# Update Gemfile: rails 5.1, pg instead of postgresql
# Update database.yml: adapter postgresql, pg-friendly database names
# Kill active_storage in environments/development.rb, application.js (5.2 thing)

```
rails db:create

rails g model Sticker url:string x:integer y:integer
rails g controller Stickers index

rails db:migrate
```

# Update routes:

`root to: 'stickers#index'`

# Update controller:

`@stickers = Sticker.all`

# Update app/views/index.html.erb:

`<%= render @stickers %>`

# Add partial app/views/_sticker.html.erb

```erb
<%= image_tag sticker.url,
      class: 'sticker',
      style: "left: #{sticker.x}px; top: #{sticker.y}px" %>
```

# Style in app/assets/stylesheets/stickers.scss:

```css
.sticker {
  position: absolute;
  max-width: 300px;
  max-height: 300px;
}
```

# Add a sample sticker:

Sticker.create(url: 'https://media1.giphy.com/media/bcKmIWkUMCjVm/200.webp#4-grid1', x: 600, y: 300)

# Add RandomStickerUrl model:

```ruby
class RandomStickerUrl
  ENDPOINT = 'http://api.giphy.com/v1/gifs/random?tag=corgi&api_key=dc6zaTOxFJmzC'

  def self.find
    new.find
  end

  def find
    parsed_response['data']['image_url']
  end

  private

  def parsed_response
    @parsed_response ||= JSON.parse(response)
  end

  def response
    Net::HTTP.get(uri)
  end

  def uri
    URI(ENDPOINT)
  end
end
```

# Add sticker creation service:

```ruby
module Services
  class StickerCreation
    def initialize(x:, y:)
      self.x = x
      self.y = y
    end

    def create
      create_sticker
      broadcast_creation
    end

    private

    attr_accessor :x, :y, :sticker

    def create_sticker
      self.sticker = Sticker.create(
        url: random_sticker_url,
        x:   x,
        y:   y
      )
    end

    def broadcast_creation

    end

    def random_sticker_url
      RandomStickerUrl.find
    end
  end
end
```

# Ensure we get our click events on our body. Add to application.css:

```css
html, body {
  width: 100%;
  height: 100%;
}
```

# Realize that jquery isn't included by default in Rails 5.1, add it:

## Gemfile
`gem 'jquery-rails'`

bundle

## application.js

```
//= require jquery
//= require jquery_ujs
```

# Now let's get into ActionCable

`rails g channel stickers`

# Add server-side method for creating sticker to stickers_channel.rb:

```ruby
  def stick(coordinates)
    Services::StickerCreation.new(
      x: coordinates['x'],
      y: coordinates['y']
    ).create
  end
```

# Add client-side method for invoking server side method to channels/stickers.coffee:

  stick: (x, y) ->
    @perform 'stick', x: x, y: y

# Listen for click to call channel JS method to stickers.coffee:

$ ->
  $('body').on 'click', (e) ->
    console.log "creating a sticker at #{e.clientX}, #{e.clientY}"
    App.stickers.stick(e.clientX, e.clientY)

# Great, so now we see the new stickers when we reload, but that sucks.. reloading sucks. We want things in realtime, man.

# Tell your server-side channel to stream, stickers_channel.rb:

stream_from "stickers"

# Tell your client-side channel to update the page, channels/stickers.coffee in `received`:

$('body').append(data.sticker)

# Broadcast sticker creation asynchronously, so let's create a job in `app/jobs/sticker_broadcast_job.rb`:

```ruby
class StickerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(sticker)
    ActionCable.server.broadcast 'stickers', sticker: render_sticker(sticker)
  end

  private

  def render_sticker(sticker)
    ApplicationController.render(
      partial: 'stickers/sticker',
      locals: { sticker: sticker }
    )
  end
end
```

# And now we actually need to tell invoke the job.. Thank god there's a service for that:

StickerBroadcastJob.perform_now(sticker)
