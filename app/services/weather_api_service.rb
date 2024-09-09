require 'net/http'

class WeatherApiService
  API_URL = 'https://api.openweathermap.org/data/2.5/weather'
  API_KEY = 'dfd1563b168e0168d41cbf19789c68c3'

  def self.fetch_weather(lat, lon)
    weather = LocationWeather.find_by(lat: lat, lon: lon)

    if weather.nil? || weather_data_expired?(weather)
      weather_data = request_weather_from_api(lat, lon)
      weather = LocationWeather.create(lat: lat, lon: lon, data: weather_data, fetched_at: Time.current) if weather.nil?
      weather.update(data: weather_data, fetched_at: Time.current) unless weather.nil?
    end

    weather
  end

  def self.fetch_weather_by_city(city, state = nil)
    uri = URI(API_URL)
    params = { q: city }
    params[:state] = state if state
    params[:appid] = API_KEY
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  private

  def self.request_weather_from_api(lat, lon)
    uri = URI("#{API_URL}?lat=#{lat}&lon=#{lon}&appid=#{API_KEY}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def self.weather_data_expired?(weather)
    weather.fetched_at < 1.hour.ago
  end
end
