## Concordia Course Ninja

#### Installation

1. Clone repo
2. `bundle install` (`gem install bundler` to install bundler)
3. `npm install`

#### Running locally

1. From the root folder, `cd app`
2. `ruby ninja.rb`
3. Find the port number in the console; connect to `http://localhost/:port`

#### Testing

`rspec spec` runs Ruby tests.

`grunt test` runs JS tests.  

All tests can be found in `spec/`

#### Deploying 

`grunt deploy` builds the app to be run on Heroku, then deploys to `concordia-calendar-ninja.herokuapp.com`.  Must have push access to `git@heroku.com:concordia-calendar-ninja.git`.