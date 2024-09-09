class LocationWeatherPresenter
  def initialize(location_weather)
    @location_weather = location_weather
  end

  def temperature
    kelvin = @location_weather&.dig('main', 'temp')
    return nil if kelvin.nil?

    (((kelvin - 273.15) * 9.0 / 5.0) + 32).round(1)
  end

  def description
    description = @location_weather.dig('weather', 0, 'description')
    description&.capitalize
  end

  def location
    @location_weather['name']
  end

  def humidity
    @location_weather.dig('main', 'humidity')
  end
end
