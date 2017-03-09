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
    from = Time.at(params[:from]||0)
    to = Time.at(params[:to]||0)
    addr = params[:url]
    result = DB.fetch("select COALESCE(MAX(duration), 0) as max, COALESCE(MIN(duration), 0) as min, COALESCE(AVG(duration), 0) as avg, relations.ratio as lost_ratio from server_statuses, servers, (select SUM(case available WHEN 0 THEN 100 else 1 END)/COUNT(*) as ratio from server_statuses) as relations where servers.id = server_statuses.server AND servers.address='#{addr}' AND server_statuses.time BETWEEN '#{from}' AND '#{to}'")
    result.first.to_json
  end

  get '/servers/pings/' do
    from = Time.at(params[:from]||0)
    to = Time.at(params[:to]||Time.now.to_i)
    addr = params[:url]
    result = DB.fetch("SELECT duration, available from server_statuses, servers WHERE servers.id=server_statuses.server AND servers.address='#{addr}' AND server_statuses.time BETWEEN '#{from}' AND '#{to}'")
    result.map(&:values).to_json
  end
end