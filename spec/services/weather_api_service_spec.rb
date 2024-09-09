require 'rails_helper'
require 'net/http'

RSpec.describe WeatherApiService, type: :service do
  describe '.fetch_weather' do
    let(:lat) { '10.99' }
    let(:lon) { '44.34' }
    let(:api_key) { 'test_api_key' }
    let(:weather_data) do
      {
        "coord" => { "lon" => lon, "lat" => lat },
        "weather" => [{ "description" => "clear sky" }],
        "main" => { "temp" => 300 }
      }
    end
    let(:location_weather) { instance_double(LocationWeather, lat: lat, lon: lon, data: weather_data, fetched_at: Time.current) }

    before do
      stub_const("WeatherApiService::API_KEY", api_key)
    end

    context 'when weather data exists and is not expired' do
      before do
        allow(LocationWeather).to receive(:find_by).with(lat: lat, lon: lon).and_return(location_weather)
        allow(WeatherApiService).to receive(:weather_data_expired?).with(location_weather).and_return(false)
      end

      it 'returns the existing weather data' do
        result = WeatherApiService.fetch_weather(lat, lon)
        expect(result).to eq(location_weather)
      end
    end

    context 'when weather data exists but is expired' do
      before do
        allow(LocationWeather).to receive(:find_by).with(lat: lat, lon: lon).and_return(location_weather)
        allow(WeatherApiService).to receive(:weather_data_expired?).with(location_weather).and_return(true)
        allow(WeatherApiService).to receive(:request_weather_from_api).with(lat, lon).and_return(weather_data)
        allow(location_weather).to receive(:update).with(data: weather_data, fetched_at: kind_of(Time))
      end

      it 'updates the weather data with new data from the API' do
        WeatherApiService.fetch_weather(lat, lon)
        expect(location_weather).to have_received(:update).with(data: weather_data, fetched_at: kind_of(Time))
      end
    end

    context 'when no weather data exists' do
      before do
        allow(LocationWeather).to receive(:find_by).with(lat: lat, lon: lon).and_return(nil)
        allow(WeatherApiService).to receive(:request_weather_from_api).with(lat, lon).and_return(weather_data)
        allow(LocationWeather).to receive(:create).with(lat: lat, lon: lon, data: weather_data, fetched_at: kind_of(Time))
      end

      it 'creates new weather data after fetching from the API' do
        WeatherApiService.fetch_weather(lat, lon)
        expect(LocationWeather).to have_received(:create).with(lat: lat, lon: lon, data: weather_data, fetched_at: kind_of(Time))
      end
    end
  end

  describe '.fetch_weather_by_city' do
    let(:city) { 'El Paso' }
    let(:state) { 'Texas' }
    let(:api_key) { 'test_api_key' }
    let(:api_url) { 'https://api.openweathermap.org/data/2.5/weather' }
    let(:response_body) do
      {
        "coord" => { "lon" => 10.99, "lat" => 44.34 },
        "weather" => [{ "description" => "clear sky" }],
        "main" => { "temp" => 300, "humidity" => 40 },
        "name" => city
      }.to_json
    end

    before do
      stub_const("WeatherApiService::API_KEY", api_key)
      allow(Net::HTTP).to receive(:get).and_return(response_body)
    end

    it 'makes a request to the weather API with city and state' do
      expect(Net::HTTP).to receive(:get).and_return(response_body)
      WeatherApiService.fetch_weather_by_city(city, state)
    end

    it 'parses the response from the API' do
      result = WeatherApiService.fetch_weather_by_city(city, state)
      expect(result).to be_a(Hash)
      expect(result['name']).to eq(city)
      expect(result['weather'][0]['description']).to eq('clear sky')
    end
  end
end
