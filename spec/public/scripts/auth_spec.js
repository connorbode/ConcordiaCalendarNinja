describe('auth.js', function () {
  it('should have a calendar object', function () {
    expect(auth.cal).toBeDefined();
    expect(auth.cal.constructor).toEqual(GoogleAuth);
  });
});