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

      getSessions: function (timeslots) {
        var service = this;
        var sessions = [];
        var timeslots = timeslots.sort(service.compareTimeslot);

        _.forEach(timeslots, function (timeslot) {
          var session, course;
          session = _.where(sessions, function (s) { return s.title === timeslot.term + ' ' + timeslot.year; })[0];

          if (session) {
            course = _.where(session.courses, { title: timeslot.course })[0];
            if (course) {
              course.timeslots.push(timeslot);
            } else {
              session.courses.push({
                title: timeslot.course,
                selected: true,
                timeslots: [ timeslot ]
              });
            }
          } else {
            sessions.push({
              title: timeslot.term + ' ' + timeslot.year,
              courses: [{
                title: timeslot.course,
                selected: true,
                timeslots: [ timeslot ]
              }]
            });
          }
        });
        return sessions;
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