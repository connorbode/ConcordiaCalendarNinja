// config =============================
var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';
var auth = new GoogleAuth();
var backend = new BackendNinja();

// app ================================
var app = {

  // initializes the app
  init: function () {
    $('#step1').css('display', 'none');
  },

  // brings the user to the first step
  start: function () {
    $('#step0').fadeOut('slow', function () {
      $('#step1').fadeIn('slow');
    });
  },

  // try to get the user's calendar
  startSteal: function () {

    var credentials = {
      username: $('#username').val(),
      password: $('#password').val(),
      term: "Fall"
    };

    backend.getTimeslots(credentials)
      .success(function (data, status, xhr) {
        alert('done');
        console.log(data);
      })
      .error (function (xhr, status, error) {
        alert('error');
        console.log(xhr);
        console.log(status);
        console.log(error);
      });
  }
}

// events =============================
$(function () {
  app.init();
});

$('#get-started-btn').on('click', function () {
  app.start();
});

$('#get-schedule-btn').on('click', function () {
  app.startSteal();
});

$('#start').on('click', function() {
	var username = $('#username').val();
	var password = $('#password').val();

  var timeslotParams = {
    'username': username,
    'password': password,
    'term': "Winter",
    'success': function(data, status, xhr) {
      console.log(data);
    },
    'error': function(xhr, status, error) {
      console.log(error);
    }
  }

	backend.getTimeslots(timeslotParams);
});




// auth.auth();

// function handleGoogleAuth(response) {
    
//     // configure calendar
//     var cal = new GoogleCalendar({
//         'apiKey': apiKey,
//         'access_token': response['access_token'],
//         'token_type': response['token_type'],
//         'timezone': "America/Montreal"
//     });
    
//     var id = "7ebovd9dqef6pe61a069a1pifg@group.calendar.google.com";
    
//     var timeslot = {
//         'end': "2014-03-24T12:40:00-05:00",
//         'start': "2014-03-24T12:30:00-05:00",
//         'summary': "test event",
//         "recurrence": "RRULE:FREQ=WEEKLY;UNTIL=20140430T000000Z",
//         'location': 'H-354'
//     };
    
//     cal.addTimeslot(id, timeslot, function(data) {
//         console.log('success!');
//     });
// }