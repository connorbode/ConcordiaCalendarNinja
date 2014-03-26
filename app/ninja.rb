require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', 'lib', 'schedule.rb')

set :server, 'webrick'

class InvalidRequest < StandardError
end

get '/' do
  "hello there!"
  Schedule.new 'f','f','Winter'
end

get '/ninja/:username/:password/:term' do
  ninja
end

def ninja
  content_type :json

  schedule = Schedule.new params[:username], params[:password], params[:term]
  h = schedule.fetch
  schedule.response.to_json

rescue InvalidRequest => exception
  status 400
  exception.message
end