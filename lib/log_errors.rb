# A basic exception handler. When an exception is raised, this rescues it, logs
# the source of the error and returns an appropriate `500 Internal Server Error`
# status.

class LogErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call
  end
end
