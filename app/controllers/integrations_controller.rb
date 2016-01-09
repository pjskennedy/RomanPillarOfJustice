class IntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  respond_to :json

  def input
    # Get all the user-names from the message
    users = params.fetch(:text, '').downcase.gsub(/[^0-9a-z ]/i, '').squeeze(' ').split(' ') - ['howitzer']

    # Update all the users to be targets
    updated_targets = users.map do |u|
      target = Target.find_by_name(u)

      target = Target.order('RANDOM()').first if target.nil? && u == 'someone'

      if target
        target.update_attributes(is_valid: true)
        target
      end
    end

    # Generate the response for slack
    names_of_bombarded = updated_targets.compact.map(&:name)

    unless names_of_bombarded.empty?
      render json: { 'text' => "Affirmative, commencing bombardment of #{names_of_bombarded.join(', ')}!" }.to_json
    else
      render json: { 'text' => 'No users to bombard.' }.to_json
    end
  end
end
