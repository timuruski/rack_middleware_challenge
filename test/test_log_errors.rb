require_relative 'test_helper'
require_relative '../lib/log_errors'

class TestLogErrors < Minitest::Test
  TEST_APP = Proc.new do |env|
    # TODO: Assign request in some way?
    raise 'Kaboom'
  end

  def setup
    @subject = RescueErrors.new(TEST_APP)
  end

  # When an exception is raised, it rescues it and responds with 500.
  def test_happy_path
    status, headers, body = @setup.call(env)
  end

  # When an exception is raised, it outputs an appropriate log message.
  # When no exception is raised, it does nothing.
end
