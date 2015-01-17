require_relative 'test_helper'
require_relative '../lib/log_errors'
require 'stringio'
require 'logger'

class TestLogErrors < Minitest::Test
  # When an exception is raised, it rescues it and responds with 500.
  def test_rescues_errors
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    begin
      app.call
    rescue RuntimeError => error
      # Minitest has no refute_raises, because reasons!
      # So we capture any raised exception and then assert it should not have
      # been raised.
      flunk 'did not rescue error'
    end
  end

  # When an exception is raised, it outputs an appropriate log message.
  def test_logs_errors
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    output = StringIO.new('')
    status, _, _ = app.call('/', 'rack.logger' => Logger.new(output))

    assert_match /ERROR -- : Kaboom/, output.string
  end

  # When an exception is raised, it returns an appropriate response.
  def test_handles_error
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    output = StringIO.new('')
    status, _, body = app.call

    assert_equal 500, status
    assert_equal ['Internal Server Error'], body
  end

  # When no exception is raised, it does nothing.
  def test_no_errors
    app = AppHarness.new(LogErrors) do
      [200, {}, ['Hello, world']]
    end

    status, _, body = app.call

    assert_equal 200, status
    assert_equal ['Hello, world'], body
  end
end
