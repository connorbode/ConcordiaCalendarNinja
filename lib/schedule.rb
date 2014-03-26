require 'date'
require 'net/http'
require 'net/http/persistent'
require 'mechanize'
require 'nokogiri'

class Schedule

  attr_reader :username, :password, :term, :recurrenceRule
  attr_accessor :html


  def initialize(username, password, term)
    @username, @password, @term = username, password, term
    @year = Time.now.year
    @recurrenceRule = getRecurrenceRule
    @@timeout = 5
  end

  def timeout
    @@timeout
  end

  def fetch
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
      raise InvalidRequest, "failed to contact MyConcordia" if code != 200

      # if the user logged in, then we can see the academic link
      links = page.links_with(:text => 'Academic')

      # log in failed
      raise InvalidRequest, "invalid MyConcordia credentials" if links.length < 1

      # navigate to timetable
      page = links[0].click
      page = page.frame_with(name: "TargetContent").click
      page = agent.page.link_with(text: term).click
      page = page.frame_with(name: "TargetContent").click

      @html = page.body

    # catch timeout errors
    rescue Net::HTTP::Persistent::Error
      raise InvalidRequest, "failed to contact MyConcordia"
    end
  end

  def response
    # use Nokogiri to parse HTML
    h = Nokogiri::HTML(html)
    timeslots = []
    h.css("tr").each do |row|
      day = 0
      row.css("td").each do |col|
        if col.attr('class') == "cusistablecontent"
          colText = col.text
          startTime = colText.slice!(/Start Time:\d{2}:\d{2}/).split(//).last(5).join
          endTime = colText.slice!(/End Time:\d{2}:\d{2}/).split(//).last(5).join
          course = colText[2..9]
          details = colText[16..-2]
          timeslots << {
              :day => day,
              :startTime => getTime(startTime, day),
              :endTime => getTime(endTime, day),
              :recurrenceRule => @recurrenceRule,
              :course => course,
              :details => details
            }
        end
        day += 1
      end
    end
    timeslots
  end

  def getTime time, day
    if @term == "Winter"
      start_day = Date.new(@year, 1, 1)
    end

    while day != start_day.wday
      start_day = start_day.next
    end

    start_day.to_time.strftime("%Y-%m-%d") + "T#{time}:00-05:00"
  end

  def getRecurrenceRule

    # fix this
    end_date = Date.new(2014, 4, 15)
    
    "RRULE:FREQ=WEEKLY;UNTIL=" + end_date.to_time.strftime("%Y-%m-%d")
  end
end
