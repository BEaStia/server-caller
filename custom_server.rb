require 'sinatra'
require 'sinatra/reloader' if development?
require './application'
require 'json'

class CustomServer < Sinatra::Base

  set :server_app, Application.new

  get '/servers' do
    Server.all.map(&:address).to_json
  end

  post '/servers/' do
    settings.server_app.add_server(params[:url])
  end

  delete '/servers/' do
    settings.server_app.remove_server(params[:url])
  end

  get '/servers/statistics/' do
    p(params[:url])
    ServerStatus.all.to_json
  end
end