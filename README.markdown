# Rack Middleware Exercise

This is a simple exercise to learn about writing Rack Middleware. The goal is
write three pieces of middleware to do three separate tasks:

  - Rescue and handle exceptions
  - Authorize requests with HTTP header
  - Handle JSONP formatted requests

The exercise will provide you with an existing environment, so you only need to
worry about the work that the middleware does. This repo includes some light
tests to guide your development.

To get started, fork this repo and open a pull request. When you think you have
a solution to one of the required middlewares, you can push up a commit. The
automated test runner will (hopefully) be notified and run the tests against
your repo.


## Getting Started

Clone the repo:

    git clone git@github.com:timuruski/rack_middleware_exercise.git

Install necessary gems:

    bundle install

Run the tests:

    rake test


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
