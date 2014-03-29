var BackendNinja = function () {
    
    "use strict";
  
  // the service url
    var url = '/';
  
  /**
   * Retrieves a Concordia user's schedule in the form of timeslots
   */
  this.getTimeslots = function(username, password, term, callback) {
    
    var data = {
      'username': username,
      'password': password,
      'term': term
    }

    console.log(JSON.stringify(data));
      
    $.ajax({
      'url': url,
      'type': 'POST',
      'crossDomain': true,
      'data': data,
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