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

      load: function () {
        service = this;
        gapiClient.client.setApiKey(apiKey);
        window.setTimeout(service.checkAuth, 1);
      },

      checkAuth: function () {
        gapiClient.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, service.handleAuthResult);
      },

      handleAuthResult: function (result) {
        if (result) {
          console.log(result);
        } else {
          console.log('blocked');
        }/*
        var authorizeButton = document.getElementById('authorize-button');
        if (authResult && !authResult.error) {
          authorizeButton.style.visibility = 'hidden';
        } else {
          authorizeButton.style.visibility = '';
          authorizeButton.onclick = handleAuthClick;
        }*/
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
            'summary': timeslot.summary,
            'recurrence': [
              timeslot.recurrence
            ]
          },
          callback: callback
        });
      }
    };
  });