# Weather App

This is a weather application built with Ruby on Rails. The app will ask for your location to use and display the local weather, also includes controls to search by city and state.

## Getting Started

Installation
To get started with the app, first clone the repo and cd into the directory:
```
$ git clone https://github.com/your-username/weather-app.git
$ cd weather-app
```
Run the following command to install all required gems:

```
$ bundle install
```
Create and migrate the database:

```
$ rails db:create
$ rails db:migrate
```
Run the application:

```
$ rails server
```
Access the app at:

http://localhost:3000

Running Tests
The project uses RSpec for testing. You can run the test suite with the following command:

```
$ bundle exec rspec
```
