require_relative 'test_helper'
require_relative '../lib/log_errors'
require 'stringio'
require 'logger'

class TestLogErrors < Minitest::Test
  # Runs a block, capturing IO and flunking on raise.
  #   output = StringIO.new
  #   status, headers, body = without_error(output) { app.call }
  #   assert_equal 200, status
  #   assert output.empty?
  def without_error(captured_err = StringIO.new)
    original_err = $stderr
    $stderr = captured_err

    yield
  rescue
    flunk 'Exception not rescued'
  ensure
    $stderr = original_err
  end

  # When an exception is raised, it rescues it and responds with 500.
  def test_rescues_errors
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    without_error do
      app.call
    end
  end

  # When an exception is raised, it outputs an appropriate log message to
  # rack.logger
  def test_logs_errors_to_rack_logger
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    logger_output = StringIO.new
    without_error do
      app.call('/', 'rack.logger' => Logger.new(logger_output))
    end

    assert_match /ERROR -- : Kaboom/, logger_output.string
  end

  # When an exception is raised, and rack.logger is missing, it outputs to
  # STDERR.
  def test_logs_errors_to_stderr
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    captured_errs = StringIO.new
    without_error(captured_errs) do
      app.call
    end

    assert_match /ERROR -- : Kaboom/, captured_errs.string
  end

  # When an exception is raised, it returns an appropriate response.
  def test_handles_error
    app = AppHarness.new(LogErrors) do
      raise 'Kaboom'
    end

    status, _, body = without_error do
      app.call
    end

    assert_equal 500, status
    assert_equal ['Internal Server Error'], body
  end

  # When no exception is raised, it does nothing.
  def test_no_errors
    app = AppHarness.new(LogErrors) do
      [200, {}, ['Hello, world']]
    end

    status, _, body = without_error do
      app.call
    end

    assert_equal 200, status
    assert_equal ['Hello, world'], body
  end
end
