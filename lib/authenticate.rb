class Authenticate
  def initialize(app, user_repo)
    @app = app
    @user_repo = user_repo
  end

  def call(env)
    @app.call(env)
  end
end
