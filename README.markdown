# Rack Middleware Exercise

This is a simple exercise to learn about writing Rack apps and middleware. The
goal is write four pieces of middleware that pass the test suite provided.

The middleware in brief:

  - Rescue and handle exceptions
  - Authorize requests via API token
  - Censor sensitive information
  - Handle JSONP formatted requests

The exercise will provide you with an existing environment, so you only need to
worry about implementing the middleware. This repo includes tests to guide your
development.

This is part of the [YYC Ruby](http://yycruby.org) February 2015 meetup
about Rack and Middleware. Slides from the talk are [available on
SpeakerDeck](https://speakerdeck.com/timuruski/rack-and-middleware).


## Getting Started

Clone the repo:

    git clone git@github.com:yycruby/middleware_exercise.git

Install necessary gems:

    bundle install

Run the tests:

    rake test

If you want to share your solutions, you can fork the repo and open a pull
request!


## Middleware Exercises

There are four pieces of middleware to implement. Here is a brief description of
what each middleware does.

### Authorize

`lib/authorize.rb`

Performs basic authorization by token, which is used to find a user and then set
the current user in the `env`. A user repository instance is passed into the
middleware when it is initialized. If a user is not found, it responds with `401
Unauthorized` status.

```ruby
use Authorize, UserRepo
run MyApp.new
```

### LogErrors

`lib/log_errors.rb`

A basic exception handler. When an exception is raised, this rescues it, logs
the source of the error and returns an appropriate `500 Internal Server Error`
status.

```ruby
use LogErrors
run MyApp.new
```

### Censored

`lib/censored.rb`

More of a fun middleware to demonstrate something that modifies the response
from a downstream app. A black list of words is passed to the initializer and it
then replaces any instances of a word with REDACTED. The `Content-Length` of the
response is also updated to reflect the changes.

```ruby
use Censored, ['Area 51', 'Roswell', 'Alien Pilot']
run MyApp.new
```


### JsonP

`lib/jsonp.rb`

Simple, but naive JSONP wrapper. When a request includes a `callback` parameter
and the response is `application/json`, it wraps the response in a JavaScript
callback and updates the response `Content-Length`.

```ruby
use JsonP
run MyApp.new
```


## Solutions

If are interested in seeing implementations for these tests, you can
check out the `solution` branch. All of the tests were implemented
against these, so the tests are real.

`git checkout solution`
