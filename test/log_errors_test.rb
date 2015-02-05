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
  rescue => error
    flunk %Q(Not rescued: #{error.class} - #{error.message})
  ensure
    $stderr = original_err
  end

  # When an exception is raised, it rescues it and responds with 500.
  def test_rescues_errors
    app = TestApp.new(LogErrors) do |env|
      raise 'Kaboom'
    end

    without_error do
      app.get('/')
    end
  end

  # When an exception is raised, it outputs an appropriate log message to
  # rack.logger
  def test_logs_errors_to_rack_logger
    app = TestApp.new(LogErrors) do |env|
      raise 'Kaboom'
    end

    logger_output = StringIO.new
    without_error do
      app.get('/', 'rack.logger' => Logger.new(logger_output))
    end

    assert_match /ERROR -- : Kaboom/, logger_output.string
  end

  # When an exception is raised, and rack.logger is missing, it outputs to
  # STDERR.
  def test_logs_errors_to_stderr
    app = TestApp.new(LogErrors) do |env|
      raise 'Kaboom'
    end

    captured_errs = StringIO.new
    without_error(captured_errs) do
      app.get('/')
    end

    assert_match /ERROR -- : Kaboom/, captured_errs.string
  end

  # When an exception is raised, and show_errors is set, the error is returned
  # as JSON.
  def test_serializes_error
    app = TestApp.new(LogErrors, show_errors: true) do |env|
      raise 'Kaboom'
    end

    captured_errs = StringIO.new
    response = without_error(captured_errs) do
      app.get('/')
    end

    assert_match 'application/json', response.content_type

    response_json = JSON.parse(response.body)
    assert_match 'Kaboom', response_json.fetch('message')
    assert_match 'RuntimeError', response_json.fetch('type')

    backtrace = response_json.fetch('backtrace')
    assert backtrace.grep(%r{test/log_errors_test.rb}).any?
  end

  # When an exception is raised, it returns an appropriate response.
  def test_handles_error
    app = TestApp.new(LogErrors) do |env|
      raise 'Kaboom'
    end

    response = without_error do
      app.get('/')
    end

    assert_equal 500, response.status
    assert_equal 'text/plain', response.content_type
    assert_equal 'Internal Server Error', response.body
  end

  # When no exception is raised, it does nothing.
  def test_no_errors
    app = TestApp.new(LogErrors) do |env|
      [200, {}, ['Hello, world']]
    end

    response = without_error do
      app.get('/')
    end

    assert_equal 200, response.status
    assert_equal 'Hello, world', response.body
  end
end
