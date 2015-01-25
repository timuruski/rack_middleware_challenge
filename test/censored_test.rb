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
    blacklist = ['Alien']
    app = TestApp.new(Censored, blacklist) do |env|
      body = '<p>We have collected ALIEN artifacts.</p>'
      [200, {}, [body]]
    end

    response = app.get('/')

    expected_body = '<p>We have collected ##### artifacts.</p>'
    assert_equal expected_body, response.body
  end
end
