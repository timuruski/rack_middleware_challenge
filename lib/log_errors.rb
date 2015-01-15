class LogErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call
  end
end
