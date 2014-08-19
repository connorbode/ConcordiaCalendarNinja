angular.module('ics.service', [])

  .service('ICSService', function () {
    return {

      generateICS: function (timeslots, callback) {
        var cal = ics();
        _.forEach(timeslots, function (timeslot) {
          cal.addEvent(timeslot.course + ' ' + timeslot.details, '', timeslot.location, timeslot.startTime, timeslot.endTime, {rule: timeslot.recurrenceRule});
        });
        cal.download('Concordia Course Schedule.ics');
        callback();
      }

    };
  });