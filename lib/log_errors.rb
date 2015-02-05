# A basic exception handler. When an exception is raised, this rescues it, logs
# the source of the error and returns an appropriate `500 Internal Server Error`
# status.

require 'logger'
require 'json'

class LogErrors
  def initialize(app, options = {})
    @app = app
    @show_errors = options.fetch(:show_errors, false)
  end

  def call(env)
    @app.call(env)
  rescue => error
    logger = env['rack.logger'] || default_logger
    logger.error error.message

    if @show_errors
      headers = {'Content-Type' => 'application/json'}
      body = JSON.dump serialize(error)
    else
      headers = {'Content-Type' => 'text/plain'}
      body = 'Internal Server Error'
    end

    [500, headers, [body]]
  end

  # Lazy-load so that $stderr reflects state at the time of call.
  def default_logger
    @default_logger ||= Logger.new($stderr)
  end

  def serialize(error)
    {type: error.class.name, message: error.message, backtrace: error.backtrace}
  end
end
