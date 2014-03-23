
$(function() {
    
    // parse the callback URL
    var cal = new GoogleAuth();
    var authInfo = cal.parseCallback(window.location);
    
    // pass the details back to the main application
    window.opener.handleGoogleAuth(authInfo);
    
    // close the popup
    window.close();
});