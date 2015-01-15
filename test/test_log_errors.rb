require_relative 'test_helper'
require_relative '../lib/log_errors'

class TestLogErrors < Minitest::Test
  TEST_APP = Proc.new do |env|
    # TODO: Assign request in some way?
    raise 'Kaboom'
  end

  def setup
    @subject = LogErrors.new(TEST_APP)
  end

  # When an exception is raised, it rescues it and responds with 500.
  def test_happy_path
    env = Rack::MockRequest.env_for
    begin
      status, headers, body = @subject.call(env)
    rescue RuntimeError => error
      # Minitest has no refute_raises, because reasons!
      # So we capture any raised exception and then assert it should not have
      # been raised.
    end

    assert_nil error
  end

  # When an exception is raised, it outputs an appropriate log message.
  # When no exception is raised, it does nothing.
end
