class ConcordiaCalendarNinja.GoogleAuthController extends ConcordiaCalendarNinja.ApplicationController
  routingKey: 'googleAuth'

  index: (params) ->
  	

  ## COULDN'T FIGURE OUT HOW TO ADD HEADERS TO BATMAN.REQUEST so I used jQuery
  googleRequest: (url, data) ->
    # Authorization header
    authHeader = "#{googleAuth.token_type} #{googleAuth.access_token}"

    # Perform request using AJAX
    $.ajax url,
        type: 'POST'
        contentType: 'application/json; charset=utf-8'
        dataType: 'json'
        data: JSON.stringify(data)
        beforeSend: (xhr) ->
          xhr.setRequestHeader 'Authorization', authHeader
        error: (jqXHR, textStatus, errorThrown) ->
            console.log(jqXHR.responseText)
        success: (data, textStatus, jqXHR) ->
            $('body').append "Successful AJAX call: #{data}"

  # Adds the calendar to Google Calendar
  addCalendar: ->

    name = "test"

    # URL to post to
    url = 'https://www.googleapis.com/calendar/v3/calendars?key=' + apiKey



    # Post data
    requestData = {
      'summary': name
    }

    @googleRequest url, requestData

  # Returns false if session is not a number
  addTimeslot: (calendarId, timeslot, session) ->

    # set recurrence end date appropriately
    now = new Date(Date.now)

    #id = "7ebovd9dqef6pe61a069a1pifg@group.calendar.google.com"
    url = "https://www.googleapis.com/calendar/v3/calendars/#{encodeURIComponent(calendarId)}/events?key=#{apiKey}"

    requestData =
    {
     "end": {
      "dateTime": "2014-02-11T12:40:00-05:00",
      "timeZone": "America/Montreal"
     },
     "start": {
      "dateTime": "2014-02-11T12:30:00-05:00",
      "timeZone": "America/Montreal"
     },
     "location": "H-354",
     "summary": "COMP 354",
     "recurrence": [
      "RRULE:FREQ=WEEKLY;UNTIL=20140430T000000Z"
     ]
    }

    @googleRequest url, requestData

  # currentDate should be Date.now
  getRecurrenceRule: (currentDate, session) ->
    # set month and day
    endDate = new Date
    switch session
      when 3
        endDate.setDate 25
        endDate.setMonth 11
      when 4
        endDate.setDate 30
        endDate.setMonth 3

    # set year
    if currentDate.getMonth <= 3
      if session in [1..3]
        endDate.setFullYear currentDate.getYear - 1
      else
        endDate.setFullYear currentDate.getYear
    else
      if session in [1..3]
        endDate.setFullYear currentDate.getYear
      else
        endDate.setFullYear currentDate.getYear + 1

    # convert to string
    rule = "RRULE:FREQ=WEEKLY;UNTIL=#{endDate.getFullYear}#{endDate.getMonth + 1}#{endDate.getDate}T000000Z"

    return rule