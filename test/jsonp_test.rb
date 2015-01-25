require_relative 'test_helper'
require_relative '../lib/jsonp'

class TestJsonP < Minitest::Test
  # When callback is provided and response content-type is JSON
  def test_wraps_with_callback
    app = TestApp.new(JsonP) do |env|
      [200, {'Content-Type' => 'application/json'}, ['{"user": "alice"}']]
    end

    response = app.get('/user', params: {'callback' => 'parseUser'})

    expected_body = 'parseUser({"user": "alice"});'
    assert_equal expected_body, response.body
  end

  # When callback is provided, the content-length is adjusted.
  def test_updates_content_length
    app = TestApp.new(JsonP) do |env|
      body = '{"user": "alice"}'
      headers = {'Content-Type' => 'application/json',
                 'Content-Length' => body.length.to_s}

      [200, headers, [body]]
    end

    response = app.get('/user', params: {'callback' => 'parseUser'})

    expected_length = 'parseUser({"user": "alice"});'.length
    assert_equal expected_length, response.content_length
  end

  # When callback is not provided, it does nothing
  def test_with_no_callback
    app = TestApp.new(JsonP) do |env|
      [200, {'Content-Type' => 'application/json'}, ['{"user": "alice"}']]
    end

    response = app.get('/user')

    expected_body = '{"user": "alice"}'
    assert_equal expected_body, response.body
  end

  # When response content-type is not JSON, it does nothing
  def test_non_json_response
    app = TestApp.new(JsonP) do |env|
      [200, {'Content-Type' => 'test/html'}, ['<p>User: alice</p>']]
    end

    response = app.get('/user', params: {'callback' => 'parseUser'})

    expected_body = '<p>User: alice</p>'
    assert_equal expected_body, response.body
  end
end
