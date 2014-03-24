
var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';
var auth = new GoogleAuth();
var backend = new BackendNinja();

$('#start').on('click', function() {
	var username = $('#username').val();
	var password = $('#password').val();
	backend.getTimeslots(username, password, 2, function(data) {
	    console.log(data);
	});
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