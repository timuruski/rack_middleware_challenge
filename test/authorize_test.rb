require_relative 'test_helper'
require_relative '../lib/authorize'

class TestAuthorize < Minitest::Test
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
    downstream_called = false
    test_user = User.new
    user_repo = UserRepo.new('abc123' => test_user)

    app = TestApp.new(Authorize, user_repo) do |env|
      assert_equal test_user, env['rack.current_user'], 'current_user not assigned'
      downstream_called = true

      [200, {}, []]
    end

    app.get('/', 'HTTP_AUTHORIZATION' => 'token abc123')

    assert downstream_called, 'downstream app not called'
  end

  # When token is passed in the query string, it assigns current_user
  # When token is passed in the query string, it calls the downstream app
  def test_token_in_query_string
    downstream_called = false
    test_user = User.new
    user_repo = UserRepo.new('abc123' => test_user)

    app = TestApp.new(Authorize, user_repo) do |env|
      assert_equal test_user, env['rack.current_user'], 'current_user not assigned'
      downstream_called = true

      [200, {}, []]
    end

    response = app.get('/?authorization_token=abc123')

    assert downstream_called, 'downstream app not called'
  end

  # When an invalid token is provided, it responds with 401 Unauthorized
  # When an invalid token is provided, it does not call the downstream app
  def test_invalid_token
    downstream_called = false
    user_repo = UserRepo.new
    app = TestApp.new(Authorize, user_repo) do |env|
      downstream_called = true
      [200, {}, ['Downstream called']]
    end

    response = app.get('/', 'HTTP_AUTHORIZATION' => 'token abc123')

    refute downstream_called, 'downstream app called'
    assert_equal 401, response.status
    assert_equal 'Unauthorized', response.body
  end

  # When no token is provided, it responds with 401 Unauthorized
  # When no token is provided, it does not call the downstream app
  def test_missing_token
    downstream_called = false
    user_repo = UserRepo.new
    app = TestApp.new(Authorize, user_repo) do |env|
      downstream_called = true
      [200, {}, ['Downstream called']]
    end

    response = app.get('/')

    assert_equal 401, response.status
    assert_equal 'Unauthorized', response.body
    refute downstream_called, 'downstream app called'
  end

  # When authorization is not a token, it responds with 401 Unauthorized
  # When an invalid token is provided, it does not call the downstream app
  def test_invalid_authorization_scheme
    downstream_called = false
    test_user = User.new
    user_repo = UserRepo.new('abc123' => test_user)

    app = TestApp.new(Authorize, user_repo) do |env|
      downstream_called = true
      [200, {}, ['Downstream called']]
    end

    response = app.get('/', 'HTTP_AUTHORIZATION' => 'Basic abc123')

    assert_equal 401, response.status
    assert_equal 'Unauthorized', response.body
    refute downstream_called, 'downstream app called'
  end
end
