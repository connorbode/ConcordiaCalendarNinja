angular.module('timeslot.service', [])

  .service('TimeslotService', function ($http) {

    return {    

      compareTimeslot: function (x, y) {
        if(x.year > y.year) {
          return -1;
        } else if (x.year < y.year) {
          return 1;
        } else {
          if(x.term === 'Winter' && (y.term === 'Summer' || y.term === 'Fall')) {
            return 1;
          } else if (x.term === 'Fall' && y.term === 'Summer') {
            return 1;
          } else if (x.term === 'Fall' && y.term === 'Winter') {
            return -1;
          } else if (x.term === 'Summer' && (y.term === 'Fall' || y.term === 'Winter')) {
            return -1;
          } else {
            if (x.course > y.course) {
              return -1;
            } else {
              return 1;
            }
          }
        }
      },

      sortTimeslots: function (timeslots) {
        var service = this;
        return timeslots.sort(service.compareTimeslot);
      },

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