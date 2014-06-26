var auth = {
  cal: new GoogleAuth(),
  auth: function () {
    var authInfo = this.cal.parseCallback(window.location);
    
    // pass the details back to the main application
    window.opener.handleGoogleAuth(authInfo);
    
    // close the popup
    window.close();
  }
};