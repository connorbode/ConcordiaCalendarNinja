require 'mechanize'

class InvalidRequest < StandardError
end

class CalendarController < ApplicationController
  # TIME_OUT = 5

  def ninja
    # validate supplied parameters
    if params[:session].nil?
      raise InvalidRequest, "session parameter missing"
    elsif not /^[\d]$/ === params[:session]
      raise InvalidRequest, "invalid session parameter"
    elsif not params[:session].to_i.between?(1, 4)
      raise InvalidRequest, "invalid session parameter"
    elsif params[:myconcordia_username].nil?
      raise InvalidRequest, "myconcordia_username parameter missing"
    elsif params[:myconcordia_password].nil?
      raise InvalidRequest, "myconcordia_password parameter missing"
    end

    term = case params[:session].to_i
    when 1 then "Summer"
    when 2 then "Summer"
    when 3 then "Fall"
    when 4 then "Winter"
    else
      raise InvalidRequest, "invalid session parameter"
    end

    schedule = Schedule.new(params[:myconcordia_username], params[:myconcordia_password], term)
    schedule.fetch

    render :json => schedule.response
  rescue InvalidRequest => exception
    render :json => {:description => exception.message}, :status => 400
  end

end
