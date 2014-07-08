
/**

  When I started this project I thought "it's small, no point in using Angular".
  So.. I used jQuery, then realized that doing a whole app in jQuery is fucked,
  then switched to Angular and as a result the front end of this app is kinda fucked.

*/
angular.module('ninja.app', [

  'angularSpinner',
  'timeslot.service'
])

  .controller('Ctrl', function ($scope, $http, TimeslotService) {

    // config =============================
    var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';
    var auth = new GoogleAuth();
    var backend = new BackendNinja();

    $scope.years = {};
    $scope.step1title = "First, let's grab your schedule";
    var step1titlefail = "Uh.. Do you know your password?";

    // retrieve schedule
    $scope.stealSchedule = function () {

      $scope.loading = true;

      TimeslotService.getTimeslots($scope.username, $scope.password)
        .success(function (data, status, xhr) {
          $scope.step = 2;
          $scope.timeslots = data;
          $scope.timeslots.sort(function (x, y) {
            if(x.year > y.year) {
              return -1;
            } else if (x.year < y.year) {
              return 1;
            } else {
              if(x.term === 'Winter' && (y.term === 'Summer' || y.term === 'Fall')) {
                return 1;
              } else if (x.term === 'Summer' && y.term === 'Fall') {
                return 1;
              } else if (x.term === 'Summer' && y.term === 'Winter') {
                return -1;
              } else if (x.term === 'Fall' && (y.term === 'Summer' || y.term === 'Winter')) {
                return -1;
              } else {
                if (x.course > y.course) {
                  return -1;
                } else {
                  return 1;
                }
              }
            }
          });
          $scope.loading = false;
        })
        .error (function (xhr, status, error) {
          $scope.step1title = step1titlefail;
          $scope.loading = false;
        });
    };

    $scope.day = function (day) {
      var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return days[day];
    };

    $scope.time = function (time) {
      return moment(time).format('HH:mm');
    };

  });


function handleGoogleAuth(response) {
  console.log(response['access_token']);
  console.log(response['token_type']);
}
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