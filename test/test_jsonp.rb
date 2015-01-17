require_relative 'test_helper'
require_relative '../lib/jsonp'

class TestJsonP < Minitest::Test
  # When callback is provided and response content-type is JSON
  def test_wraps_callback
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-type' => 'application/json'}, ['{"user": "alice"}']]
    end

    _, _, body = app.call('/users/123', params: {'callback' => 'parseUser'})

    expected_body = ['parseUser({"user": "alice"});']
    assert_equal body, expected_body
  end

  # When callback is not provided, it does nothing
  def test_missing_callback
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-type' => 'application/json'}, ['{"user": "alice"}']]
    end

    _, _, body = app.call('/users/123')

    expected_body = ['{"user": "alice"}']
    assert_equal body, expected_body
  end

  # When response content-type is not JSON, it does nothing
  def test_harness
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-type' => 'test/html'}, ['<p>User: alice</p>']]
    end

    _, _, body = app.call('/users/123')

    expected_body = ['<p>User: alice</p>']
    assert_equal body, expected_body
  end
end
