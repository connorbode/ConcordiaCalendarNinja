class Timeslot
	def initialize(startTime, endTime, day, course, details)
		
		# Start and end time of the timeslot
		@start = startTime
		@end = endTime
		
		# numeric representation of the day of the week (0 = Sunday, 1 = Monday, ..) 
		@day = day
		
		# the course code for the course
		@course = course
		
		# further details (lecture or tutorial, room #, etc)
		@details = details
	end
end
