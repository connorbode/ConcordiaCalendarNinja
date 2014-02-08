require Rails.root + "lib/assets/error.rb"
require Rails.root + "lib/assets/timeslot.rb"
require 'mechanize'

class CalendarController < ApplicationController

  cattr_accessor :timeout
  @@timeout = 5

  def ninja


  	# did anything go wrong?
  	error = false
  	@error_types = [
  		Error.new(0, "session parameter missing"),
  		Error.new(1, "invalid session parameter"),
  		Error.new(2, "myconcordia_username parameter missing"),
  		Error.new(3, "myconcordia_password parameter missing"),
  		Error.new(4, "failed to contact MyConcordia"),
  		Error.new(5, "invalid MyConcordia credentials")
  	]

  	# validate supplied parameters
  	if params[:session].nil?
  		error = 0
  	elsif not /^[\d]$/ === params[:session]
  		error = 1
  	elsif not params[:session].to_i.between?(1, 4)
  		error = 1
  	elsif params[:myconcordia_username].nil?
  		error = 2
  	elsif params[:myconcordia_password].nil?
  		error = 3
  	else
  		case params[:session].to_i
  		when 1
  			# need to update this when I know what happens for spring / summer division of timetables
  			session = "Summer"
  		when 2
  			session = "Summer"
  		when 3
  			session = "Fall"
  		when 4
  			session = "Winter"
  		end

  		# attempt to get schedule
		response = getSchedule(params[:myconcordia_username], params[:myconcordia_password], session)

		# if getSchedule returns an integer, it is an error code
  		if response.is_a? Integer
  			error = response
  		end
  	end


  	status = 200
   	if error.is_a? Integer

   		# set error message
   		case error
   		when 0
	  		response = Error.new(0, "session parameter missing")
	  	when 1
	  		response = Error.new(1, "invalid session parameter")
	  	when 2
	  		response = Error.new(2, "myconcordia_username parameter missing")
	  	when 3
	  		response = Error.new(3, "myconcordia_password parameter missing")
	  	when 4
	  		response = Error.new(4, "failed to contact MyConcordia")
	  	when 5
	  		response = Error.new(5, "invalid MyConcordia credentials")
	  	end

	  	# set appropriate status
   		if error == 4
   			error 
   			status = 500
   		else
  			status = 400
  		end
  	end


  	# output response
  	render json: response, status: status
  end






  def getSchedule(username, password, term)
  	
  	begin

	  	# use mechanize to navigate through MyConcordia
	  	agent = Mechanize.new

	  	# set the agent to timeout after 5 seconds
	  	agent.read_timeout = @@timeout

	  	# base page is http, but there is an instant redirect to https, which
	  	# mechanize follows.  fails for some reason when set to https initially.
	  	page = agent.get "http://myconcordia.ca/"

	  	# log user in
	  	form = page.form 'login'
	  	form.userid = username
	  	form.pwd = password
	  	page = agent.submit(form, form.buttons.first)

	  	# get status code
	  	code = page.code.to_i

	  	# if the user logged in, then we can see the academic link
	  	links = page.links_with(:text => 'Academic')
	  	if links.length > 0

	  		# navigate to timetable
			page = links[0].click
		  	page = page.frame_with(name: "TargetContent").click
		  	page = agent.page.link_with(text: term).click
		  	page = page.frame_with(name: "TargetContent").click

		  	# parse timetable
		  	return self.class.parseTimetable(page.body)

		else
			# failed to log in
			return 5
	  	end

	  # catch timeout errors
	  rescue Net::HTTP::Persistent::Error
	  	return 4
	  end
  end



  def self.parseTimetable(pageHtml)

  	# use Nokogiri to parse HTML
	html = Nokogiri::HTML(pageHtml)
  	timeslots = []
  	html.css("tr").each {|row|
  		day = 0
  		row.css("td").each {|col|
  			if col.attr('class') == "cusistablecontent"
	  			colText = col.text
	  			startTime = colText.slice!(/Start Time:\d{2}:\d{2}/).split(//).last(5).join
	  			endTime = colText.slice!(/End Time:\d{2}:\d{2}/).split(//).last(5).join
	  			course = colText[2..9]
	  			details = colText[16..-2]
	  			timeslots.push Timeslot.new startTime, endTime, day, course, details
  			end
  			day += 1
  		}
  	}
  	return timeslots

  end
end
