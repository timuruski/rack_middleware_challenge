require 'bundler/setup'

require 'rack/mock'
require 'minitest/autorun'


# Wraps middleware around a block that acts as a downstream app.
# Arguments from the initializer are passed to the middleware.
# The harness also provides a call method, which generates an env
# for the request. Usage example:
#
#   subject = TestApp.new(MyMiddleware, 'foo') do |env|
#     [200, {}, ['Hello world']]
#   end
#
#   response = subject.get('/foo/bar')
class TestApp
  def initialize(middleware, *args, &app)
    @app = middleware.new(app, *args)
    @app = Rack::Builder.new do
      use Rack::Lint
      use middleware, *args
      run app
    end
  end

  def get(*args)
    Rack::MockRequest.new(@app).get(*args)
  end

  def call(*args)
    env = Rack::MockRequest.env_for(*args)
    @app.call(env)
  end
end
