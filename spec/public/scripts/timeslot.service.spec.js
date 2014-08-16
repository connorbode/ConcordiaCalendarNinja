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

    describe('compareTimeslot()', function () {
      it('compares properly based on year', function () {
        var x = { year: 2011 };
        var y = { year: 2012 };
        expect(TimeslotService.compareTimeslot(x, y)).toEqual(1);
        expect(TimeslotService.compareTimeslot(y, x)).toEqual(-1);
      });

      it('compares properly based on term', function () {
        var x = { year: 2011, term: 'Summer' };
        var y = { year: 2011, term: 'Fall' };
        var z = { year: 2011, term: 'Winter' };
        var t = TimeslotService.compareTimeslot;
        expect(t(x, y)).toEqual(-1);
        expect(t(y, x)).toEqual(1);
        expect(t(y, z)).toEqual(-1);
        expect(t(z, y)).toEqual(1);
        expect(t(x, z)).toEqual(-1);
        expect(t(z, x)).toEqual(1);
      });

      it('compares properly based on course', function () {
        var x = { year: 2011, term: 'Summer', course: 'a' };
        var y = { year: 2011, term: 'Summer', course: 'b' };
        var t = TimeslotService.compareTimeslot;
        expect(t(x, y)).toEqual(1);
        expect(t(y, x)).toEqual(-1);
      });
    });

  });
});