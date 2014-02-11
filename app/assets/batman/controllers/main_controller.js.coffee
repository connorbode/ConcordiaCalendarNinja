class ConcordiaCalendarNinja.MainController extends ConcordiaCalendarNinja.ApplicationController
  routingKey: 'main'

  googleAuth = {}
  timeslots = []
  apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ'

  index: (params) ->
    @set 'myconcordia_username', ''
    @set 'myconcordia_password', ''
    @set 'session', 3
    # parse token if access token is in uri
    if /access_token/i.test(window.location)
      @parseToken window.location

  getSchedule: ->
  	alert @get 'session'
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
	  		@addSchedule response
    
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
      # params.push {
      #   'key': temp2[0],
      #   'val': temp2[1]
      # }
    ) for t in temp
    # googleAuth = params
    console.log googleAuth

  # Adds the calendar to Google Calendar
  addCalendar: ->

    name = "test"

    # URL to post to
    url = 'https://www.googleapis.com/calendar/v3/calendars?key=' + apiKey

    # Post data
    requestData = {
      'summary': name
    }

    # Authorization header
    authHeader = "#{googleAuth.token_type} #{googleAuth.access_token}"

    ## COULDN'T FIGURE OUT HOW TO ADD HEADERS TO BATMAN.REQUEST
    # Create the request
    #request = new Batman.Request
    #  url: url
    #  method: 'POST'
    #  data: 
    ## COULDN'T FIGURE OUT HOW TO ADD HEADERS TO BATMAN.REQUEST

    console.log "auth header: #{authHeader}"
    console.log requestData

    # Perform request using AJAX
    $.ajax url,
        type: 'POST'
        dataType: 'application/json'
        data: requestData
        beforeSend: (xhr) ->
          xhr.setRequestHeader 'Authorization', authHeader
        error: (jqXHR, textStatus, errorThrown) ->
            $('body').append "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
            $('body').append "Successful AJAX call: #{data}"

  addSchedule: (response) ->
    timeslots = response
    console.log timeslots


  @accessor 'fullName', ->
    "#{@get('firstName')} #{@get('lastName')}"
