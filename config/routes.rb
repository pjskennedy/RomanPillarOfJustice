Rails.application.routes.draw do
  # Endpoint to upload gifs
  post 'reaction' => 'reaction#create'
  # Endpoint to mark targets
  post 'input' => 'integrations#input'
  # Endpoint for RPOJ to poll targets
  get '/targets' => 'targets#index'
end
