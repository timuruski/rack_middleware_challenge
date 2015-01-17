require_relative 'test_helper'
require_relative '../lib/log_errors'

class TestLogErrors < Minitest::Test
  # When an exception is raised, it rescues it and responds with 500.
  # When an exception is raised, it outputs an appropriate log message.
  def test_rescues_errors
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    begin
      status, headers, body = app.call

      assert_equal status, 500
    rescue RuntimeError => error
      # Minitest has no refute_raises, because reasons!
      # So we capture any raised exception and then assert it should not have
      # been raised.
      flunk 'did not rescue error'
    end
  end

  # When no exception is raised, it does nothing.
  def test_no_errors
    app = AppHarness.new(LogErrors) do
      [200, {}, ['Hello, world']]
    end

    status, headers, body = app.call

    assert_equal status, 200
    assert_equal body, ['Hello, world']
  end
end
