class ConcordiaCalendarNinja.MainController extends ConcordiaCalendarNinja.ApplicationController
  routingKey: 'main'

  googleAuth = {}
  timeslots = []
  apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ'
  calendarId = ''
  session = ''

  index: (params) ->
    @set 'myconcordia_username', ''
    @set 'myconcordia_password', ''
    @set 'session', 3

    # parse token if access token is in uri
    if /access_token/i.test(window.location)
      @parseToken window.location

    console.log (@getStartDate 3, 3).toJSON()



  # # Returns false if session is not a number ->

  getSchedule: ->
  	session = @get 'session'
  	request = new Batman.Request
  		url: "/"
  		method: "POST"
  		data: 
  			myconcordia_username: @get 'myconcordia_username'
  			myconcordia_password: @get 'myconcordia_password'
  			session: @get 'session'
  		error: (xhr) =>
  			if xhr.status == 403
  				@rateLimitExceeded()
  			else
	  			error = JSON.parse(xhr.responseText)
	  			@handleError(error)
	  	success: (response) =>
	  		@receivedSchedule response


  # addTimeslot: (calendarId, startTime, endTime, location, summary, recurrenceRule)
  receivedSchedule: (response) ->

    # set timeslots
    timeslots = response    
    console.log timeslots

    # add the calendar
    @addCalendar()
    
    
  handleError: (error) ->
  	console.log error

  rateLimitExceeded: ->


  launchGoogleAuth: ->
    oauthUrl = 'https://accounts.google.com/o/oauth2/auth?'
    validUrl = 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token='
    scope = 'https://www.googleapis.com/auth/calendar'
    clientid = '375598335107-4uro6idndhosr9k1qas7v6f9fuhfpcsq.apps.googleusercontent.com'
    redirect = 'https://concordia-calendar-ninja.herokuapp.com/'
    type = 'token'
    url = oauthUrl + 'scope=' + scope + '&client_id=' + clientid + '&redirect_uri=' + redirect + '&response_type=' + type
    window.location = url

  parseToken: (url) ->
    split = url.href.lastIndexOf "#"
    temp = url.href.substring(split + 1, url.href.length)
    temp = temp.split "&"
    params = []
    (
      temp2 = t.split "="
      googleAuth[temp2[0]] = temp2[1]
    ) for t in temp
    console.log googleAuth

  googleRequest: (url, data, successCallback) ->
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
            successCallback data

  # Adds the calendar to Google Calendar
  addCalendar: ->

    name = "Concordia Schedule"

    # URL to post to
    url = 'https://www.googleapis.com/calendar/v3/calendars?key=' + apiKey

    # Post data
    requestData = {
      'summary': name
    }

    setId = (data) => 
      calendarId = data.id
      @addTimeslots()

    @addTimeslots()
    #@googleRequest url, requestData, setId 


  # Adds timeslots
  addTimeslots: ->

    # set current date
    currDate = new Date(Date.now())

    # get the recurrence rule
    recurrenceRule = @getRecurrenceRule currDate, session

    timeslot = [timeslots[0]]
    
    # iterate timeslots
    (
      # get the start date
      startDate = @getStartDate t.day, session
      endDate = new Date(startDate)

      # get the hours & minutes
      startHour = t.start.substr(0,2)
      startMin = t.start.substr(3,2)
      endHour = t.end.substr(0,2)
      endMin = t.end.substr(3,2)

      # set the hours & minutes
      console.log "toJSON: " + startDate.toJSON()
      console.log "pritn: " + startDate.getFullYear() + startDate.getMonth() + startDate.getDate()
      console.log "start hour #{startHour} start minutes #{startMin}"
      startDate.setHours(startHour, startMin)
      endDate.setHours(endHour, endMin)
      # endDate.setHours(endHour)
      # endDate.setHours(endMin)

      # convert start and end dates to JSON & add time zone difference
      startTime = startDate.toJSON()[0..-2] + "-05:00"
      endTime = endDate.toJSON()[0..-2] + "-05:00"

      console.log "start time: #{startTime}"
      console.log "end time: #{endTime}"

      # @addTimeslot(calendarId, startTime, endTime, t.details, t.title, recurrenceRule)

    ) for t in timeslot


  # addTimeslot: (calendarId, startTime, endTime, location, summary, recurrenceRule) ->


    #id = "7ebovd9dqef6pe61a069a1pifg@group.calendar.google.com"

    # requestData =
    # {
    #  "end": {
    #   "dateTime": "2014-02-11T12:40:00-05:00",
    #   "timeZone": "America/Montreal"
    #  },
    #  "start": {
    #   "dateTime": "2014-02-11T12:30:00-05:00",
    #   "timeZone": "America/Montreal"
    #  },
    #  "location": "H-354",
    #  "summary": "COMP 354",
    #  "recurrence": [
    #   "RRULE:FREQ=WEEKLY;UNTIL=20140430T000000Z"
    #  ]
    # }


  # Returns false if session is not a number
  addTimeslot: (calendarId, startTime, endTime, location, summary, recurrenceRule) ->

    # request URL
    url = "https://www.googleapis.com/calendar/v3/calendars/#{encodeURIComponent(calendarId)}/events?key=#{apiKey}"

    # request data
    requestData = {
      'start': {
        'dateTime': startTime,
        'timeZone': 'America/Montreal'
      },
      'end': {
        'dateTime': endTime,
        'timeZone': 'America/Montreal'
      },
      'location': location,
      'summary': summary,
      'recurrence': [
        recurrenceRule
      ]
    }

    # send request
    @googleRequest url, requestData




  # currentDate should be Date.now
  getRecurrenceRule: (currentDate, session) ->

    # set month and day
    endDate = new Date(Date.now())
    switch session
      when 3
        endDate.setMonth 11
        endDate.setDate 25
      when 4
        endDate.setMonth 3
        endDate.setDate 30

    # set year
    endDate = @setYear(new Date(Date.now()), session, endDate)

    # convert to string
    json = endDate.toJSON()
    str = json.substr(0,4)+json.substr(5,2)+json.substr(8,3)+'000000Z'
    rule = "RRULE:FREQ=WEEKLY;UNTIL=#{str}"

    return rule

  # get the first xday of the session (ie. first Tuesday of the Fall semester)
  getStartDate: (day, session) ->
    # get the current date
    date = new Date(Date.now())
    date.setHours(0,0,0,0)

    # set the proper year
    date = @setYear date, session, date

    # set the month
    switch session
      when 3 then date.setMonth 8
      when 4 then date.setMonth 0

    # set the day
    date.setDate 1

    givenDay = date.getDay()

    while date.getDay() != day
      date.setDate(date.getDate() + 1)

    return date

  setYear: (currentDate, session, date) ->    
    if currentDate.getMonth() <= 3
      if session in [1..3]
        date.setFullYear(currentDate.getFullYear() - 1)
      else
        date.setFullYear(currentDate.getFullYear())
    else
      if session in [1..3]
        date.setFullYear currentDate.getFullYear()
      else
        date.setFullYear(currentDate.getFullYear() + 1)

    return date