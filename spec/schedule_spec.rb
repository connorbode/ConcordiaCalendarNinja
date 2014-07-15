require_relative '../app/schedule.rb'
require_relative '../app/error.rb'
require 'rspec'
require 'fakeweb'
require 'tzinfo'

describe 'schedule.rb' do
  describe 'getTime' do
    it 'returns the correct time' do
      s = Schedule.new "test", "test"
      expect(s.getTime("11:45", 1, "Fall", 2014)[0..-6]).to eq "2014-09-01T11:45:00-"
      expect(s.getTime("13:15", 5, "Fall", 2014)[0..-6]).to eq "2014-09-05T13:15:00-"
      expect(s.getTime("13:15", 4, "Winter", 2015)[0..-6]).to eq "2015-01-01T13:15:00-"
      expect(s.getTime("20:30", 3, "Winter", 2015)[0..-6]).to eq "2015-01-07T20:30:00-"
    end
  end

  describe 'getRecurrenceRule' do
    it 'returns the appropriate recurrence rule' do 
      s = Schedule.new "test", "test"
      expect(s.getRecurrenceRule "Fall", 2014).to eq "RRULE:FREQ=WEEKLY;UNTIL=2014-12-25"
      expect(s.getRecurrenceRule "Winter", 2099).to eq "RRULE:FREQ=WEEKLY;UNTIL=2099-04-30"
    end
  end

  describe 'timeout' do
    it 'returns the timeout' do
      s = Schedule.new "test", "test"
      expect(s.timeout.class).to eq Fixnum
    end
  end

  describe 'fetch' do
    it 'throws error on login failure' do
      login = File.read('./spec/fixtures/login.html')
      FakeWeb.register_uri(:get, 
        "https://my.concordia.ca/psp/upprpr9/?cmd=login&languageCd=ENG", 
        :body => login, 
        :content_type => "text/html")
      FakeWeb.register_uri(:post, 
        "https://my.concordia.ca/psp/upprpr9/?cmd=login&languageCd=ENG", 
        :body => login,
        :content_type => "text/html")
      FakeWeb.register_uri(:get, 
        "https://my.concordia.ca/psp/upprpr9/EMPLOYEE/EMPL/s/WEBLIB_CONCORD.CU_SIS_INFO.FieldFormula.IScript_Fall?PORTALPARAM_PTCNAV=CU_MY_CLASS_SCHEDULE_FALL&EOPP.SCNode=EMPL&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=CU_ACADEMIC&EOPP.SCLabel=Academic&EOPP.SCPTfname=CU_ACADEMIC&FolderPath=PORTAL_ROOT_OBJECT.CU_ACADEMIC.CU_MY_CLASS_SHEDULE.CU_MY_CLASS_SCHEDULE_FALL&IsFolder=false", 
        :body => login,
        :content_type => "text/html")
      s = Schedule.new "test", "test"
      expect{s.fetch}.to raise_error(InvalidRequest)
    end
  end

  describe 'getOffset' do
    it 'gets the proper offset during dst' do
      s = Schedule.new 'test', 'test'
      expect(s.getOffset).to eq "-04:00"
    end
  end
end 