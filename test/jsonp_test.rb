require_relative 'test_helper'
require_relative '../lib/jsonp'

class TestJsonP < Minitest::Test
  # When callback is provided and response content-type is JSON
  def test_wraps_callback
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-Type' => 'application/json'}, ['{"user": "alice"}']]
    end

    _, _, body = app.call('/users/123', params: {'callback' => 'parseUser'})

    expected_body = ['parseUser({"user": "alice"});']
    assert_equal expected_body, body
  end

  # When callback is provided, the content-length is adjusted.
  def test_content_length
    app = AppHarness.new(JsonP) do |env|
      body = '{"user": "alice"}'
      headers = {'Content-Type' => 'application/json',
                 'Content-Length' => body.length}

      [200, headers, [body]]
    end

    _, headers, _ = app.call('/users/123', params: {'callback' => 'parseUser'})

    expected_length = 'parseUser({"user": "alice"});'.length
    assert_equal expected_length, headers['Content-Length']
  end

  # When callback is not provided, it does nothing
  def test_missing_callback
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-Type' => 'application/json'}, ['{"user": "alice"}']]
    end

    _, _, body = app.call('/users/123')

    expected_body = ['{"user": "alice"}']
    assert_equal expected_body, body
  end

  # When response content-type is not JSON, it does nothing
  def test_non_json_response
    app = AppHarness.new(JsonP) do |env|
      [200, {'Content-Type' => 'test/html'}, ['<p>User: alice</p>']]
    end

    _, _, body = app.call('/users/123')

    expected_body = ['<p>User: alice</p>']
    assert_equal expected_body, body
  end
end
