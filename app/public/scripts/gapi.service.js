angular.module('gapi.service', [])

  .service('GapiService', function () {
    var clientId = '375598335107-4uro6idndhosr9k1qas7v6f9fuhfpcsq.apps.googleusercontent.com';
    var apiKey = 'AIzaSyBDzlWciuiWaIDY5Hdaw5M9WnlLo0_pAsQ';
    var scopes = 'https://www.googleapis.com/auth/calendar';
    var gapiClient;

    return {

      setClient: function (client) {
        gapiClient = client;
      },

      load: function () {
        var service = this;
        gapiClient.client.setApiKey(apiKey);
        window.setTimeout(service.checkAuth, 1);
      },

      checkAuth: function () {
        gapiClient.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
      },

      handleAuthResult: function (result) {
        var authorizeButton = document.getElementById('authorize-button');
        if (authResult && !authResult.error) {
          authorizeButton.style.visibility = 'hidden';
        } else {
          authorizeButton.style.visibility = '';
          authorizeButton.onclick = handleAuthClick;
        }
      }
    };
  });