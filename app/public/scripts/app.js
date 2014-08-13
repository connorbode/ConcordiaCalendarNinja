
/**

  When I started this project I thought "it's small, no point in using Angular".
  So.. I used jQuery, then realized that doing a whole app in jQuery is fucked,
  then switched to Angular and as a result the front end of this app is kinda fucked.

*/
angular.module('ninja.app', [

  'angularSpinner',
  'timeslot.service',
  'gapi.service'
])

  .controller('Ctrl', function ($scope, $http, TimeslotService, GapiService) {

    // config =============================
    var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';

    $scope.step = 0;
    $scope.years = {};
    $scope.step1title = "First, let's grab your schedule";
    var step1titlefail = "Uh.. Do you know your password?";
    var $canvas = $('#canvas');
    var canvas = $canvas[0];
    var c = canvas.getContext('2d');
    var center;

    // retrieve schedule
    $scope.stealSchedule = function () {

      $scope.loading = true;

      TimeslotService.getTimeslots($scope.username, $scope.password)
        .success(function (data, status, xhr) {
          $scope.step = 2;
          $scope.sessions = TimeslotService.getSessions(data);
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

    $scope.auth = function () {
      GapiService.setClient(gapi);
      GapiService.load();
    };

    $scope.createCalendar = function () {
      GapiService.addCalendar('ConcordiaCalendarNinja', function (returned) {
        $scope.$apply(function () {
          $scope.addedTimeslots = 0;
        });
        _.each($scope.timeslots, function (timeslot) {
          GapiService.addTimeslot(returned.id, timeslot, function (response) {
            $scope.$apply(function () {
              $scope.addedTimeslots++;
            });
          });
        });
      });
    };

    function setCanvasSize () {
      $canvas.width(window.innerWidth).height(window.innerHeight);
      $canvas.attr('width', window.innerWidth).attr('height', window.innerHeight);
    }

    function clearCanvas () {
      canvas.width = canvas.width;
    }

    function rad (deg) {
      return deg * Math.PI / 180;
    }

    function getPt (length, angle) {
      var coords = {};
      while (angle >= 360) {
        angle -= 360;
      }
      if (angle < 90) {
        coords.x = Math.sin(rad(angle)) * length;
        coords.y = - Math.cos(rad(angle)) * length;
      } else if (angle >= 90 && angle < 180) {
        angle -= 90;
        coords.x = Math.cos(rad(angle)) * length;
        coords.y = Math.sin(rad(angle)) * length;
      } else if (angle >= 180 && angle < 270) {
        angle -= 180;
        coords.x = - Math.sin(rad(angle)) * length;
        coords.y = Math.cos(rad(angle)) * length;
      } else {
        angle -= 270;
        coords.x = - Math.cos(rad(angle)) * length;
        coords.y = - Math.sin(rad(angle)) * length;
      }
      return coords;
    }

    function drawSun (center, radius) {
      c.beginPath();
      c.moveTo(center.x, center.y);
      c.arc(center.x, center.y, radius, 0, Math.PI * 2);
      c.fill();
    }

    function drawRays (center, numberOfRays, offset) {
      var length = Math.sqrt(Math.pow(center.x, 2) + Math.pow(center.y, 2))
        , angle = offset || 0
        , sliceSize = 360 / numberOfRays / 2
        , startPt
        , endPt;

      _.forEach(_.range(0, numberOfRays), function () {
        startPt = getPt(length, angle);
        endPt = getPt(length, angle + sliceSize);
        c.beginPath();
        c.moveTo(center.x, center.y);
        c.lineTo(center.x + startPt.x, center.y + startPt.y);
        c.lineTo(center.x + endPt.x, center.y + endPt.y);
        c.fill();
        angle += 2 * sliceSize;
      });
    }

    function draw (params, offset) {
      setCanvasSize();
      c.fillStyle = params.color;
      drawSun(center, params.radius);
      drawRays(center, params.numberOfRays, offset);
    }

    function spin (params) {
      var offset = 0;
      setInterval(function () {
        draw(params, offset);
        offset += params.offsetIncrement;
        if (offset >= 360) {
          offset -= 360;
        }
      }, params.interval); 
    }

    function setCenter () {
      center = {
        x: window.innerWidth / 2,
        y: window.innerHeight / 2
      };
    }

    setCenter();
    $(window).on('resize', function () {
      setCenter();
      setCanvasSize();
    });

    spin({
      color: '#FEC33B',
      radius: 100,
      numberOfRays: 20,
      interval: 10,
      offsetIncrement: 0.05
    });
  });


function handleGoogleAuth(response) {
  console.log(response['access_token']);
  console.log(response['token_type']);
}