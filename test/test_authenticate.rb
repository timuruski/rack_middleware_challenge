require_relative 'test_helper'
require_relative '../lib/authenticate'

# TODO: Need some sort of User repository to authenticate against.

class TestAuthenticate < Minitest::Test
  class User; end
  class UserRepo
    def initialize(users = {})
      @users = users
    end

    def find_by_token(token)
      @users[token]
    end
  end

  # When a valid token is provided, it assigns current_user
  # When a valid token is provided, it calls the downstream app
  def test_valid_token
    test_user = User.new
    user_repo = UserRepo.new('abc123' => test_user)

    app = AppHarness.new(Authenticate, user_repo) do |env|
      assert_equal env['rack.current_user'], test_user, 'current_user not assigned'
    end

    app.call('/', 'HTTP_AUTHORIZATION' => 'token abc123')
  end

  # When an invalid token is provided, it responds with 401 Unauthorized
  # When an invalid token is provided, it does not call the downstream app
  def test_invalid_token
    user_repo = UserRepo.new
    downstream_called = false

    app = AppHarness.new(Authenticate, user_repo) do |env|
      downstream_called = true
      [200, {}, ['Downstream called']]
    end

    status, _, body = app.call('/', 'HTTP_AUTHORIZATION' => 'token abc123')

    assert_equal status, 401
    refute downstream_called
  end
end
