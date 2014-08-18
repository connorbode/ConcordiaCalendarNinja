angular.module('ics.service', [])

  .service('ICSService', function () {
    return {

      generateICS: function (timeslots) {
        var cal = ics();
        _.forEach(timeslots, function (timeslot) {
          cal.addEvent(timeslot.course + ' ' + timeslot.details, '', timeslot.location, timeslot.startTime, timeslot.endTime);
        });
        cal.download('Concordia Course Schedule.ics');
      }

    };
  });