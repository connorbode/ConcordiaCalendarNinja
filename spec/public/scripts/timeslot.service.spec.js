describe('timeslot.service', function () {

  var $httpBackend;
  var TimeslotService;
  
  beforeEach(module('timeslot.service'));
  beforeEach(inject(function (_$httpBackend_, _TimeslotService_) {
    $httpBackend = _$httpBackend_;
    TimeslotService = _TimeslotService_;
  }));

  describe('TimeslotService', function () {

    describe('getTimeslots()', function () {

      it('posts appropriately', function () {
        var user = 'testuser';
        var pass = 'testpass';
        $httpBackend.expect('POST', '/', {username: user, password: pass}).respond(200);
        TimeslotService.getTimeslots(user, pass);
        $httpBackend.flush();
      });

    });

  });
});