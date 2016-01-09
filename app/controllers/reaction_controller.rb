class ReactionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    r = Reaction.new(params.permit(:animation))
    if r.save
      payload = {
        text: "Reaction: #{(URI(request.url) + r.animation.url)}",
        channel: '#realtime',
        username: 'The Roman Pillar of Justice',
        icon_emoji: ':roman:'
      }.to_json

      # Again running out of time for this hackday, ignore the crap code
      cmnd = "curl -X POST --data-urlencode 'payload=" + payload + "' #{SLACK_URL}"
      puts cmnd
      `#{cmnd}`

      head :ok
    else
      head :bad_request
    end
  end

  def show
  end
end
