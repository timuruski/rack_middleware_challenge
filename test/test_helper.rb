require 'bundler/setup'

require 'rack/mock'
require 'minitest/autorun'


# Wraps middleware around a block that acts as a downstream app.
# Arguments from the initializer are passed to the middleware.
# The harness also provides a call method, which generates an env
# for the request. Usage example:
#
#   subject = AppHarness.new(MyMiddleware, 'foo') do |env|
#     [200, {}, ['Hello world']]
#   end
#
#   status, header, body, subject.call('/foo/bar')
class AppHarness
  def initialize(middleware, *args, &app)
    @app = middleware.new(app, *args)
  end

  def call(*args)
    env = Rack::MockRequest.env_for(*args)
    @app.call(env)
  end
end
