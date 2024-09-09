class LocationWeatherController < ApplicationController
  def show
    lat = params[:latitude]
    lon = params[:longitude]

    @location_weather = WeatherApiService.fetch_weather(lat, lon)

    if @location_weather
      @presenter = LocationWeatherPresenter.new(@location_weather.data)
      render :show
    else
      render plain: "No weather data available", status: :not_found
    end
  end

  def search_results
    city = params[:city]
    state = params[:state]

    if city && state
      @search_weather = WeatherApiService.fetch_weather_by_city(city, state)
    end

    if @search_weather&.dig('main', 'temp')
      @search_presenter = LocationWeatherPresenter.new(@search_weather) if @search_weather
      render :search_results
    else
      render plain: "No weather data available", status: :not_found
    end
  end
end
