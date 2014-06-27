var GoogleAuth = function() {
    
    /**
     * Launches a popup to authenticate the user for the given scopes
     */
    this.auth = function() {
    
        oauthUrl = 'https://accounts.google.com/o/oauth2/auth?';
        validUrl = 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=';
        scope = 'https://www.googleapis.com/auth/calendar';
        clientid = '375598335107-4uro6idndhosr9k1qas7v6f9fuhfpcsq.apps.googleusercontent.com';
        redirect = 'https://concordia-calendar-ninja.herokuapp.com/auth.html';
        type = 'token';
        url = oauthUrl + 'scope=' + scope + '&client_id=' + clientid + '&redirect_uri=' + redirect + '&response_type=' + type;
        window.open(url, 'auth', 'height=400,width=400');
    }
    
    /**
     * Retrieves all Google auth information from the callback URL
     * @param url the URL to parse
     * @return an array of auth information
     */
    this.parseCallback = function(url) {
        var split, temp, temp2, params, i;
        split = url.href.lastIndexOf('#');
        temp = url.href.substring(split + 1, url.href.length);
        temp = temp.split("&");
        params = [];
        
        for(i = 0; i < temp.length; i++) {
            temp2 = temp[i].split("=");
            params[temp2[0]] = temp2[1];
        }
        
        return params;
    }
}