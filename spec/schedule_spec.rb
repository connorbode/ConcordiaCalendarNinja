require_relative '../app/schedule.rb'
require 'rspec'

describe 'schedule.rb' do
  describe 'getTime' do
    it 'returns the correct time' do
      s = Schedule.new "test", "test"
      expect(s.getTime "11:45", 1, "Fall", 2014).to eq "2014-09-01T11:45:00-05:00"
      expect(s.getTime "13:15", 5, "Fall", 2014).to eq "2014-09-05T13:15:00-05:00"
      expect(s.getTime "13:15", 4, "Winter", 2015).to eq "2015-01-01T13:15:00-05:00"
      expect(s.getTime "20:30", 3, "Winter", 2015).to eq "2015-01-07T20:30:00-05:00"
    end
  end

  describe 'getRecurrenceRule' do
    it 'returns the appropriate recurrence rule' do 
      s = Schedule.new "test", "test"
      expect(s.getRecurrenceRule "Fall", 2014).to eq "RRULE:FREQ=WEEKLY;UNTIL=2014-12-25"
      expect(s.getRecurrenceRule "Winter", 2099).to eq "RRULE:FREQ=WEEKLY;UNTIL=2099-04-30"
    end
  end
end 