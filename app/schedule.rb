require 'date'
require 'net/http'
require 'net/http/persistent'
require 'mechanize'
require 'nokogiri'

class Schedule

  attr_reader :username, :password, :recurrenceRule
  attr_accessor :html

  @@TERMS = ['Summer', 'Fall', 'Winter']
  @@timeout = 5

  def initialize(username, password)
    @username, @password = username, password
    @recurrenceRule = getRecurrenceRule
    @html = {}
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
      page = agent.get "https://my.concordia.ca/psp/upprpr9/?cmd=login&languageCd=ENG"

      # log user in
      form = page.form 'login'
      form.userid = username
      form.pwd = password
      page = agent.submit(form, form.buttons.first)

      # not sure why this page works, but it does.
      home_page = agent.get "https://my.concordia.ca/psp/upprpr9/EMPLOYEE/EMPL/s/WEBLIB_CONCORD.CU_SIS_INFO.FieldFormula.IScript_Fall?PORTALPARAM_PTCNAV=CU_MY_CLASS_SCHEDULE_FALL&EOPP.SCNode=EMPL&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=CU_ACADEMIC&EOPP.SCLabel=Academic&EOPP.SCPTfname=CU_ACADEMIC&FolderPath=PORTAL_ROOT_OBJECT.CU_ACADEMIC.CU_MY_CLASS_SHEDULE.CU_MY_CLASS_SCHEDULE_FALL&IsFolder=false"

      # get status code
      code = home_page.code.to_i
      raise InvalidRequest, "failed to contact MyConcordia" if code != 200

      # log in failed
      links = home_page.links_with(text: "Academic")
      raise InvalidRequest, "invalid MyConcordia credentials" if links.length < 1

      @@TERMS.each do |term|
        page = home_page.link_with(text: term).click
        page = page.iframe_with(name: "TargetContent").click
        @html[term] = page.body
      end

    # catch timeout errors
    rescue Net::HTTP::Persistent::Error
      raise InvalidRequest, "failed to contact MyConcordia"
    end
  end

  def response
    timeslots = []

    @@TERMS.each do |term|
      page = @html[term]
      # use Nokogiri to parse HTML
      h = Nokogiri::HTML(page)

      # get year
      year = nil
      h.css("p.cusisheaderdata").each do |result|

        # if we find the year, then the schedule has some content
        if result.text[0, term.length] == term
          year = result.text[-4,4].to_i 
          puts "#{term} #{year}"
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
                    :startTime => getTime(startTime, day, term, year),
                    :endTime => getTime(endTime, day, term, year),
                    :recurrenceRule => @recurrenceRule,
                    :course => course,
                    :details => details
                  }
              end
              day += 1
            end
          end
        end
      end
    end
    timeslots
  end

  def getTime time, day, term, year
    case term
    when "Winter"
      start_day = Date.new(year, 1, 1)
    when "Fall"
      start_day = Date.new(year, 9, 1)
    when "Summer"
      start_day = Date.new(year, 6, 1)
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
