var BackendNinja = function () {
    
    "use strict";
  
  // the service url
    var url = '/';
  
  /**
   * Retrieves a Concordia user's schedule in the form of timeslots
   */
  this.getTimeslots = function(params) {
    
    var data = {
      'username': params.username,
      'password': params.password,
      'term': params.term
    }
      
    return $.ajax({
      'url': url,
      'type': 'POST',
      'crossDomain': true,
      'data': data
    });
  }
}