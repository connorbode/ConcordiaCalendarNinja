require 'thin'
require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), '..', 'lib', 'schedule.rb')

set :bind, "0.0.0.0"
set :server, 'thin'

class InvalidRequest < StandardError
end

get '/ninja/:username/:password/:term' do
  ninja
end

get '/' do
  File.read(File.join('public', 'index.html'))
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