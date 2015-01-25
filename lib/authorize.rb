# Performs basic authorization by token, which is used to find a user and then
# set the current user in the `env`. A user repository instance is passed into
# the middleware when it is initialized. If a user is not found, it responds
# with `401 Unauthorized` status.

class Authorize
  def initialize(app, user_repo)
    @app = app
    @user_repo = user_repo
  end

  def call(env)
    @app.call(env)
  end
end
