class CalendarController < ApplicationController
  def ninja

  	require Rails.root + "lib/assets/error.rb"
  	require Rails.root + "lib/assets/timeslot.rb"
  	require 'mechanize'

  	# error types
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
  		response = @error_types[0]
  	elsif not params[:session].to_i.between?(1, 4)
  		response = @error_types[1]
  	elsif params[:myconcordia_username].nil?
  		response = @error_types[2]
  	elsif params[:myconcordia_password].nil?
  		response = @error_types[3]
  	else
  		case params[:session].to_i
  		when 1
  			# need to update this when I know what summer looks like.. 
  			session = "Summer"
  		when 2
  			session = "Summer"
  		when 3
  			session = "Fall"
  		when 4
  			session = "Winter"
  		end
  		response = getSchedule(params[:myconcordia_username], params[:myconcordia_password], session)
  	end

  	# output response
  	render json: response
  end






  def getSchedule(username, password, term)
  	
  	# use mechanize to navigate through MyConcordia
  	agent = Mechanize.new

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
	  	return parseTimetable(page.body)

	else
		# failed to log in
		return @error_types[5]
  	end
  end



  def parseTimetable(pageHtml)

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
