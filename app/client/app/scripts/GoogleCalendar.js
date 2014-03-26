var GoogleCalendar = function(config) {
    
  // configure calendar
  var apiKey = config.apiKey;
  var access_token = config.access_token;
  var token_type = config.token_type;
  
  var timezone = "America/Montreal";
  if(typeof(config.timezone) !== 'undefined') {
    timezone = config.timezone;
  }
  
  /**
   * Creates a new calendar
   * @param name the name of the new calendar
   * @param callback the callback function to handle the success callback
   */
  this.addCalendar = function(name, callback) {
    var url = 'https://www.googleapis.com/calendar/v3/calendars?key=' + apiKey;
    var requestData = {
      'summary': name
    }
    makeRequest(url, requestData, callback);
  }
    
    
  /**
   * Adds a timeslot to a calendar
   * @param calendarId the calendar to add the timeslot to
   * @param timeslot an object containing details for the event to be added (start, end, location, summary, recurrence)
   * @param callback the function to call when the request succeeds
   */
  this.addTimeslot = function(calendarId, timeslot, callback) {
      
    var requestData;
    var url;
    
    // compile the request URL
    url = "https://www.googleapis.com/calendar/v3/calendars/" + encodeURIComponent(calendarId) + "/events?key=" + apiKey;
      
    // compile the request data
    requestData = {
      'start': {
        'dateTime': timeslot.start,
        'timeZone': timezone
      },
      'end': {
        'dateTime': timeslot.end,
        'timeZone': timezone
      },
      'location': timeslot.location,
      'summary': timeslot.summary,
      'recurrence': [
        timeslot.recurrence
      ]
    }
    
    console.log(requestData);
    
    // make the request
    makeRequest(url, requestData, callback);
  }
    
    
  /**
   * General POST request.  Sets up request authorization properly.
   * @param url the url to make the request to
   * @param data the data to send with the request
   * @param successCallback the function to call when the request is successful
   */
  var makeRequest = function(url, data, successCallback) {
        
    var header = token_type + " " + access_token;
        
    console.log("URL: " + url);
    
    $.ajax(url, {
      'type': 'POST',
      'dataType': 'json',
      'data': JSON.stringify(data),
      'contentType': 'application/json; charset=utf-8',
      'beforeSend': function(xhr) {
        xhr.setRequestHeader('Authorization', header);
      },
      'success': function(data, status, xhr) {
        successCallback(data);
      },
      'error': function(xhr, status, error) {
        console.log("ERROR:");
        console.log(error);
        console.log("XHR:");
        console.log(xhr);
        console.log("STATUS:");
        console.log(status);
      }
    });
  }
}