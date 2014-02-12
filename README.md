## Concordia Course Ninja

The purpose of this project is to log in to a Concordia student's MyConcordia profile, retrieve that student's course schedule for a given semester and import the schedule to a Google Calendar account

__This project is currently incomplete__

The application has been designed for deployment on Heroku.  The application has two routes: `GET /` and `POST /`.  The `POST` route (described in more detail below) accepts a student's MyConcordia credentials and a school semester as parameters and returns the students schedule in a JSON array of [__Timeslot__](https://github.com/connorbode/ConcordiaCalendarNinja/blob/master/lib/assets/timeslot.rb) objects.  The `GET` route returns a Batman.js application which interacts with the server-side

#### Server-side

The server-side application is built using Ruby on Rails.  The main functionality is done using the [calendar controller](https://github.com/connorbode/ConcordiaCalendarNinja/blob/master/app/controllers/calendar_controller.rb).  The `POST /` route calls `CalendarController::ninja`, which uses the Mechanize gem to crawl through the Concordia website to retrieve the students schedule.  After the schedule is received, the Nokogiri gem is used to parse the schedule into Timeslots, which are then rendered as a JSON response. 

The following is a diagram of the server flow:

[![](http://oi57.tinypic.com/25qw6r8.jpg)](http://oi57.tinypic.com/25qw6r8.jpg)

The [test code for the Calendar Controller](https://github.com/connorbode/ConcordiaCalendarNinja/blob/master/test/functional/calendar_controller_test.rb) tests the following:

- the appropriate error is returned if a request does not include the session or includes an invalid session (session being an integer representation of the desired school term)
- the appropriate errors are returned if either the MyConcordia username or password are missing
- the appropriate error is returned if Mechanize times out when contacting MyConcordia
- the appropriate error is returned if the MyConcordia credentials were invalid
- an array of timeslots are returned if the algorithm execution succeeds




#### Client

The client-side is currently incomplete
