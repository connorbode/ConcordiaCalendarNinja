class Schedule

  cattr_accessor :timeout
  self.timeout = 5

  attr_reader :username, :password, :term
  attr_accessor :html

  def initialize(username, password, term)
    @username, @password, @term = username, password, term
      # attempt to get schedule
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
    h.css("tr").each {|row|
      day = 0
      row.css("td.cusistablecontent").each {|col|
          colText = col.text
          startTime = colText.slice!(/Start Time:\d{2}:\d{2}/).split(//).last(5).join
          endTime = colText.slice!(/End Time:\d{2}:\d{2}/).split(//).last(5).join
          course = colText[2..9]
          details = colText[16..-2]
          timeslots << {
              :startTime => startTime,
              :endTime => endTime,
              :day => day,
              :course => course,
              :details => details
            }
        day += 1
      }
    }
    timeslots
  end
end
