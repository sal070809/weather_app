Rails.application.routes.draw do

  root "location_weather#show"
  get 'weather/', to: 'location_weather#show'
  post 'weather', to: 'location_weather#show'
  get 'weather_results', to: 'location_weather#search_results'
end
