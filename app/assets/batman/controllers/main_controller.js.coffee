class ConcordiaCalendarNinja.MainController extends ConcordiaCalendarNinja.ApplicationController
  routingKey: 'main'

  index: (params) ->
    @set 'myconcordia_username', ''
    @set 'myconcordia_password', ''
    @set 'display', ''
    @set 'session', '3'

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
	  	success: (xhr) =>
	  		console.log xhr

  handleError: (error) ->
  	@set 'display', error.description

  rateLimitExceeded: ->
  	@set 'display', 'rate limit exceeded'

  @accessor 'fullName', ->
    "#{@get('firstName')} #{@get('lastName')}"
