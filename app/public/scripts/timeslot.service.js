angular.module('timeslot.service', [])

  .service('TimeslotService', function ($http) {

    return {

      getTimeslots: function (username, password) {

        var data = {
          username: username,
          password: password
        };

        return $http({
          url: '/',
          method: 'POST',
          data: data
        });
      }
    };
  });