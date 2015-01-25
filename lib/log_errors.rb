# A basic exception handler. When an exception is raised, this rescues it, logs
# the source of the error and returns an appropriate `500 Internal Server Error`
# status.

require 'logger'

class LogErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue => error
    logger = env['rack.logger'] || default_logger
    logger.error error.message

    [500, {}, ['Internal Server Error']]
  end

  # Lazy-load so that $stderr reflects state at the time of call.
  def default_logger
    @default_logger ||= Logger.new($stderr)
  end
end
