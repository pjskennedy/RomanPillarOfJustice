class TargetsController < ApplicationController
  respond_to :json

  def index
    render json: Target.get_targets.to_json
  end
end
