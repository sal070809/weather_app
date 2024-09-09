require 'rails_helper'

RSpec.describe LocationWeatherController, type: :controller do
  describe 'GET show' do
    let(:lat) { '44.34' }
    let(:lon) { '10.99' }
    let(:weather_data) do
      {
        "coord" => { "lon" => lon, "lat" => lat },
        "weather" => [{ "description" => "clear sky" }],
        "main" => { "temp" => 300 }
      }
    end

    let(:location_weather) { double('LocationWeather', data: weather_data) }
    let(:presenter) { instance_double(LocationWeatherPresenter, location: 'test_location', temperature: 80, description: 'clear sky', humidity: 10) }

    context 'when weather data is available' do
      before do
        allow(WeatherApiService).to receive(:fetch_weather).with(lat, lon).and_return(location_weather)
        allow(LocationWeatherPresenter).to receive(:new).with(weather_data).and_return(presenter)
        get :show, params: { latitude: lat, longitude: lon }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(:ok)
      end

    end

    context 'when no weather data is available' do
      before do
        allow(WeatherApiService).to receive(:fetch_weather).with(lat, lon).and_return(nil)
        get :show, params: { latitude: lat, longitude: lon }
      end

      it 'renders a 404 status with a not found message' do
        expect(response.body).to eq("No weather data available")
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET search_results' do
    let(:city) { 'El Paso' }
    let(:state) { 'Texas' }
    let(:search_weather_data) do
      {
        "coord" => { "lon" => 10.99, "lat" => 44.34 },
        "weather" => [{ "description" => "clear sky" }],
        "main" => { "temp" => 300 }
      }
    end

    let(:search_presenter) { instance_double(LocationWeatherPresenter, location: 'Los Angeles', temperature: 80, description: 'clear sky', humidity: 10) }

    context 'when search data is available' do
      before do
        allow(WeatherApiService).to receive(:fetch_weather_by_city).with(city, state).and_return(search_weather_data)
        allow(LocationWeatherPresenter).to receive(:new).with(search_weather_data).and_return(search_presenter)
        get :search_results, params: { city: city, state: state }
      end

      it 'returns a 200 status code' do
        expect(response).to have_http_status(:ok)
      end

    end

    context 'when no search data is available' do
      before do
        allow(WeatherApiService).to receive(:fetch_weather_by_city).with(city, state).and_return(nil)
        get :search_results, params: { city: city, state: state }
      end

      it 'renders a 404 status with a not found message' do
        expect(response.body).to eq("No weather data available")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
