angular.module('gapi.service', [
  'app.config'
])

  .service('GapiService', function (CONFIG) {
    var clientId = CONFIG.google.clientId;
    var apiKey = CONFIG.google.apiKey;
    var scopes = CONFIG.google.scopes;
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
        gapiClient.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, this.handleAuthResult);
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