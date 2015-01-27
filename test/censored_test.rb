require_relative 'test_helper'
require_relative '../lib/censored'

class TestCensored < Minitest::Test
  # When the response contains blacklisted words, they are censored.
  def test_censors_words
    blacklist = ['Area 51', 'UFO']
    app = TestApp.new(Censored, blacklist) do |env|
      body = '<p>Report on Area 51 and UFO technology.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>Report on ####### and ### technology.</p>'
    assert_equal expected_body, response.body
  end

  # When the response differing cases of blacklisted words, they are censored.
  def test_is_case_insensitive
    blacklist = ['alien']
    app = TestApp.new(Censored, blacklist) do |env|
      body = '<p>We have recovered ALIEN artifacts.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>We have recovered ##### artifacts.</p>'
    assert_equal expected_body, response.body
  end

  # When the blacklist contains a regular expression, it is used.
  def test_accepts_regexp
    blacklist = [/a+lien/i]
    app = TestApp.new(Censored, blacklist) do |env|
      body = '<p>We have recovered AAAAAALIEN artifacts.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>We have recovered ########## artifacts.</p>'
    assert_equal expected_body, response.body
  end

  # When a custom replacement string is provided, it is used.
  def test_custom_replacement_string
    blacklist = ['alien']
    app = TestApp.new(Censored, blacklist, 'REDACTED') do |env|
      body = '<p>We have recovered alien artifacts.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>We have recovered REDACTED artifacts.</p>'
    assert_equal expected_body, response.body
  end

  # When a custom replacement proc is provided, it is used.
  def test_custom_replacement_proc
    blacklist = ['alien']
    replacement = ->(match) { '*' * match.to_s.length }
    app = TestApp.new(Censored, blacklist, replacement) do |env|
      body = '<p>We have recovered alien artifacts.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>We have recovered ***** artifacts.</p>'
    assert_equal expected_body, response.body
  end
end
