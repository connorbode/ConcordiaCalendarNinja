// config =============================
var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';
var auth = new GoogleAuth();
var backend = new BackendNinja();

// app ================================
var app = {

  // initializes the app
  init: function () {
    $('#step1').css('display', 'none');
    $('#step1spinnercontainer').css('display', 'none');
    $('#step2').css('display', 'none');

    // start spinner
    var opts = {
      lines: 13,
      length: 20,
      width: 10,
      radius: 30,
      corners: 1,
      rotate: 0,
      direction: 1,
      color: '#000',
      speed: 1,
      trail: 60,
      shadow: false,
      hwaccel: false,
      className: 'spinner',
      zIndex: 2e9,
      top: '50%',
      left: '50%'
    };
    var target = $('#step1spinner')[0];
    var spinner = new Spinner(opts).spin(target);
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
      term: "Winter"
    };

    $('#step1form').fadeOut('slow', function () {
      $('#step1spinnercontainer').fadeIn('slow');
    });

    backend.getTimeslots(credentials)
      .success(function (data, status, xhr) {
        var form = $('#step2Accordion');
        $.each(data, function (index, timeslot) {
          form.append(generateAccordion(timeslot, index));
        });
        $('#step1').fadeOut('slow', function () {
          $('#step2').fadeIn('slow');
        });
      })
      .error (function (xhr, status, error) {
        $('#step1header').text('Uh...');
        $('#step1text').text("The credentials you gave me didn't work.. You know your own password, right?");
        $('#step1spinnercontainer').fadeOut('slow', function () {
          $('#step1form').fadeIn('slow');
        });
      });
  }
}

// events =============================
$(function () {
  app.init();
});

// step 0
$('#get-started-btn').on('click', function () {
  app.start();
});

// step 1 
$('#get-schedule-btn').on('click', function () {
  app.startSteal();
});







// helpers ================================
function generateAccordion (timeslot, index) {
  var parent = "step2Accordion";
  var collapse = "step2AccordionCollapse" + index;
  var elem = '';
  elem += '<div class="panel panel-default">';
  elem += '<div class="panel-heading">';
  elem += '<h4 class="panel-title">';
  elem += '<input type="checkbox"> &nbsp; ';
  elem += '<a data-toggle="collapse" data-parent="#' + parent + '" href="#' + collapse + '">';
  elem += timeslot.term + " " + timeslot.year + " - " + timeslot.course;
  elem += '</a>';
  elem += '</h4>';
  elem += '</div>';
  elem += '<div id="' + collapse + '" class="panel-collapse collapse">';
  elem += '<div class="panel-body">';

  elem += '<div class="form-group">';
  elem += '<label class="col-sm-3 control-label">Title</label>';
  elem += '<div class="col-sm-8">';
  elem += '<input class="form-control" type="text" value="' + timeslot.course + ' ' + timeslot.details + '">';
  elem += '</div></div>';

  elem += '<div class="form-group">';
  elem += '<label class="col-sm-3 control-label">Location</label>';
  elem += '<div class="col-sm-8">';
  elem += '<input class="form-control" type="text" value="">';
  elem += '</div></div>';

  elem += '</div>';
  elem += '</div>';

  return elem;
}




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