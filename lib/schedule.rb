require 'date'

class Schedule

  cattr_accessor :timeout
  self.timeout = 5

  attr_reader :username, :password, :term, :recurrenceRule
  attr_accessor :html

  def initialize(username, password, term)
    @username, @password, @term = username, password, term
    @recurrenceRule = getRecurrenceRule
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
      row.css("td.cusistablecontent").each do |col|
        colText = col.text
        startTime = colText.slice!(/Start Time:\d{2}:\d{2}/).split(//).last(5).join
        endTime = colText.slice!(/End Time:\d{2}:\d{2}/).split(//).last(5).join
        course = colText[2..9]
        details = colText[16..-2]
        timeslots << {
            :startTime => startTime,
            :endTime => endTime,
            :day => day,
            :startDate => getStartDate,
            :recurrenceRule => @recurrenceRule,
            :course => course,
            :details => details
          }
        day += 1
      end
    end
    timeslots
  end

  def getStartDate

  end

  def getRecurrenceRule
    year = Time.now.year
    if @term == "Winter"
      end_date = Date.new(year, 4, 15)
    end

    str = end_date.year.to_s + end_date.month.to_s + end_date.day.to_s + "T000000Z"

    "RRULE:FREQ=WEEKLY;UNTIL=#{str}"
  end
end
