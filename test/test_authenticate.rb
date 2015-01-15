require_relative 'test_helper'
require_relative '../lib/authenticate'

# Need some sort of User repository to authenticate against.

class TestAuthenticate < Minitest::Test
  TEST_APP = Proc.new do |env|
    [200, {}, ['Hello world!']]
  end

  def setup
    @subject = Authenticate.new(TEST_APP)
  end

  # When a valid token is provided, it assigns current_user
  def test_happy_path
  end

  # When a valid token is provided, it calls the downstream app
  # When an invalid token is provided, it responds with 401 Unauthorized
end
