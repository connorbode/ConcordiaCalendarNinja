var BackendNinja = function () {
    
    "use strict";
  
  // the service url
    var url = '/';
  
  /**
   * Retrieves a Concordia user's schedule in the form of timeslots
   */
  this.getTimeslots = function(username, password, session, callback) {
    
    var data = {
      'myconcordia_username': username,
      'myconcordia_password': password,
      'session': session
    }
      
    $.ajax({
      'url': url,
      'type': 'POST',
      'crossDomain': true,
      'dataType': 'json',
      'data': JSON.stringify(data),
      'contentType': 'application/json; charset=utf-8',
      'success': function(data, status, xhr) {
        callback(data);
      },
      'error': function(xhr, status, error) {
        console.log("ERROR!");
        console.log(xhr);
        console.log(status);
      }
    });
  }
}