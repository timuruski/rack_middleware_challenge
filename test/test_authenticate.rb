require_relative 'test_helper'
require_relative '../lib/authenticate'

# TODO: Need some sort of User repository to authenticate against.

class TestAuthenticate < Minitest::Test
  def setup
    test_app = Proc.new do |env|
      assert_equal env['rack.current_user'], '123', 'expected current_user id to be assigned'
    end

    user_repo = Object.new
    @subject = Authenticate.new(test_app, user_repo)
  end

  # When a valid token is provided, it assigns current_user
  def test_assigns_current_user
    env = Rack::MockRequest.env_for('/', 'HTTP_AUTHORIZATION' => 'token abc123')
    @subject.call(env)
  end

  # When a valid token is provided, it calls the downstream app
  # When an invalid token is provided, it responds with 401 Unauthorized
end
