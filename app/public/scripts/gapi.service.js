angular.module('gapi.service', [
  'app.config'
])

  .service('GapiService', function (CONFIG) {
    var clientId = CONFIG.google.clientId;
    var apiKey = CONFIG.google.apiKey;
    var scopes = CONFIG.google.scopes;
    var timezone = CONFIG.google.timezone;
    var gapiClient;
    var service = null;

    return {

      setClient: function (client) {
        gapiClient = client;
      },

      setService: function () {
        service = this;
      },

      load: function (callback) {
        service = this;
        gapiClient.client.setApiKey(apiKey);
        window.setTimeout(function () {
          service.checkAuth(callback)
        }, 1);
      },

      checkAuth: function (callback) {
        gapiClient.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, callback);
      },

      addCalendar: function (name, callback) {
        gapiClient.client.request({
          path: 'calendar/v3/calendars',
          method: 'POST',
          body: {
            summary: name
          },
          callback: callback
        });
      },

      addTimeslot: function (calendarId, timeslot, callback) {
        gapiClient.client.request({
          path: 'calendar/v3/calendars/' + encodeURIComponent(calendarId) + '/events',
          method: 'POST',
          body: {
            'start': {
              'dateTime': timeslot.startTime,
              'timeZone': timezone
            },
            'end': {
              'dateTime': timeslot.endTime,
              'timeZone': timezone
            },
            'location': timeslot.location,
            'summary': timeslot.course + ' ' + timeslot.details,
            'recurrence': [
              // timeslot.recurrenceRule
            ]
          },
          callback: callback
        });
      }
    };
  });