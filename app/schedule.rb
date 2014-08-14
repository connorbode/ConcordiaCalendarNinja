require 'date'
require 'net/http'
require 'net/http/persistent'
require 'mechanize'
require 'nokogiri'
require 'tzinfo'

class Schedule

  attr_reader :username, :password, :recurrenceRule
  attr_accessor :html

  @@TERMS           = ['Fall', 'Winter']
  @@timeout         = 5
  @@login_page_url  = "https://my.concordia.ca/psp/upprpr9/?cmd=login&languageCd=ENG"
  @@main_page_url   = "https://my.concordia.ca/psp/upprpr9/EMPLOYEE/EMPL/s/WEBLIB_CONCORD.CU_SIS_INFO.FieldFormula.IScript_Fall?PORTALPARAM_PTCNAV=CU_MY_CLASS_SCHEDULE_FALL&EOPP.SCNode=EMPL&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=CU_ACADEMIC&EOPP.SCLabel=Academic&EOPP.SCPTfname=CU_ACADEMIC&FolderPath=PORTAL_ROOT_OBJECT.CU_ACADEMIC.CU_MY_CLASS_SHEDULE.CU_MY_CLASS_SCHEDULE_FALL&IsFolder=false"

  def initialize(username, password)
    @username, @password = username, password
    @html = {}
  end

  def timeout
    @@timeout
  end

  def fetch
    begin
      agent = Mechanize.new
      agent.read_timeout = @@timeout
      page = agent.get @@login_page_url

      form = page.form 'login'
      form.userid = username
      form.pwd = password
      page = agent.submit(form, form.buttons.first)

      home_page = agent.get @@main_page_url
      links = home_page.links_with(text: "Academic")
      raise InvalidRequest, "invalid MyConcordia credentials" if links.length < 1

      @@TERMS.each do |term|
        page = home_page.link_with(text: term).click
        page = page.iframe_with(name: "TargetContent").click
        @html[term] = page.body
      end

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
          if term == 'Winter'
            year += 1
          end
          h.css("tr").each do |row|
            day = 0
            row.css("td").each do |col|
              if col.attr('class') == "cusistablecontent"
                colText = col.text
                startTime = colText.slice!(/Start Time:\d{2}:\d{2}/).split(//).last(5).join
                endTime = colText.slice!(/End Time:\d{2}:\d{2}/).split(//).last(5).join
                course = colText[2..9]
                details = colText[16..-2]
                location = colText[16..-2]
                if details.match(/Lec/)
                  details = "Lecture"
                elsif details.match(/Tut/)
                  details = "Tutorial"
                elsif details.match(/Lab/)
                  details = "Lab"
                end
                if location.match(/SGW [A-Z]+-[0-9]+/)
                  location = location.match(/SGW [A-Z]+-[0-9]+/)
                elsif location.match(/SGW/)
                  location = "SGW"
                elsif location.match(/LOY/)
                  location = location.match(/LOY [A-Z]+-[0-9]+/)
                elsif location.match(/LOY/)
                  location = "LOY"
                end
                timeslots << {
                    :day => day,
                    :startTime => getTime(startTime, day, term, year),
                    :endTime => getTime(endTime, day, term, year),
                    :recurrenceRule => getRecurrenceRule(term, year),
                    :course => course,
                    :details => details,
                    :term => term,
                    :year => year,
                    :location => location
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
      start_day = Date.new(year, 1, 1,)
    when "Fall"
      start_day = Date.new(year, 9, 1)
    # Need to figure out specifics for summer.
    # when "Summer"
    #   start_day = Date.new(year, 6, 1)
    end

    while day != start_day.wday
      start_day = start_day.next
    end

    start_day.to_time.strftime("%Y-%m-%d") + "T#{time}:00" + getOffset
  end

  def getOffset
    tz = TZInfo::Timezone.get('America/Montreal')
    current = tz.current_period
    offset_seconds = current.utc_total_offset
    offset_hours = offset_seconds / 3600
    offset_str = "-0" + offset_hours.to_s[1..2] + ":00"
    offset_str
  end

  def getRecurrenceRule term, year

    case term
    when "Winter"
      end_date = Date.new(year, 4, 30)
    when "Fall"
      end_date = Date.new(year, 12, 25)
    end
    
    "RRULE:FREQ=WEEKLY;UNTIL=" + end_date.to_time.strftime("%Y-%m-%d")
  end
end
