require_relative 'test_helper'
require_relative '../lib/jsonp'

class TestJsonP < Minitest::Test
  TEST_APP = Proc.new do |env|
    [200, {'Content-type' => 'application/json'}, ['{"user": "alice"}']]
  end

  def setup
    @subject = JsonP.new(TEST_APP)
  end

  # When callback is provided and response content-type is JSON
  def test_happy_path
    env = {}
    expected_body = 'parseUser({"user": "alice"});'
    _, _, body = @subject.call(env)
    assert_equal body, expected_body
  end

  # When callback is not provided, it does nothing
  # When response content-type is not JSON, it does nothing
end
