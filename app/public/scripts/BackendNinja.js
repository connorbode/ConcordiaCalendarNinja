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
      
    $.ajax({
      'url': url,
      'type': 'POST',
      'crossDomain': true,
      'data': data,
      'success': function(data, status, xhr) {
        params.success(data, status, xhr);
      },
      'error': function(xhr, status, error) {
        params.error(xhr, status, error);
      }
    });
  }
}