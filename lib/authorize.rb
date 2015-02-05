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
    token = find_auth_token(env)
    user = find_user(token)

    return [401, {}, ['Unauthorized']] if user.nil?

    env['rack.current_user'] = user
    @app.call(env)
  end

  def find_auth_token(env)
    if token = env['HTTP_AUTHORIZATION']
      parse_token_auth(token)
    else
      Rack::Request.new(env).params['authorization_token']
    end
  end

  def find_user(token)
    return if token.nil?

    @user_repo.find_by_token(token)
  end

  def parse_token_auth(auth)
    kind, value = auth.to_s.split(' ', 2)
    kind == 'token' ? value : nil
  end
end
