require 'thin'
require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), 'schedule.rb')
require File.join(File.dirname(__FILE__), 'error.rb')

set :bind, "0.0.0.0"
set :server, 'thin'

get '/ninja/:username/:password' do
  ninja
end

get '/' do
  File.read(File.join('public', 'index.html'))
end

post '/' do
  ninja
end

def ninja
  content_type :json

  schedule = Schedule.new params[:username], params[:password]

  h = schedule.fetch
  schedule.response.to_json

rescue InvalidRequest => exception
  status 400
  exception.message
end