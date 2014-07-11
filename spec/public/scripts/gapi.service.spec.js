describe('gapi.service', function () {

  var GapiService;
  var gapi;

  beforeEach(module('gapi.service'));
  beforeEach(inject(function ($injector) {
    GapiService = $injector.get('GapiService');
    gapi = {
      client: {
        setApiKey: function (blah) {}
      }
    };
    GapiService.setClient(gapi);
  }));

  describe('load()', function () {
    it('loads..', function () {
      spyOn(gapi.client, 'setApiKey');
      spyOn(GapiService, 'checkAuth');
      GapiService.load();
      expect(gapi.client.setApiKey).toHaveBeenCalled();
      setTimeout(function () {
        expect(GapiService.checkAuth).toHaveBeenCalled();
      }, 100);
    });
  });
});