require_relative 'test_helper'
require_relative '../lib/authenticate'

# TODO: Need some sort of User repository to authenticate against.

class TestAuthenticate < Minitest::Test
  class User; end
  class UserRepo
    def initialize(users)
      @users = users
    end

    def find_by_token(token)
      @users[token]
    end
  end

  # When a valid token is provided, it assigns current_user
  def test_assigns_current_user
    test_user = User.new
    user_repo = UserRepo.new('abc123' => test_user)

    test_app = Proc.new do |env|
      assert_equal env['rack.current_user'], test_user, 'current_user not assigned'
    end

    subject = Authenticate.new(test_app, user_repo)
    env = Rack::MockRequest.env_for('/', 'HTTP_AUTHORIZATION' => 'token abc123')

    subject.call(env)
  end

  # When a valid token is provided, it calls the downstream app
  # When an invalid token is provided, it responds with 401 Unauthorized
end
