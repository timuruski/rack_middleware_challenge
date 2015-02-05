# More of a fun middleware to demonstrate something that modifies the response
# from a downstream app. A black list of words is passed to the initializer and
# it then replaces any instances of a word with REDACTED. The `Content-Length`
# of the response is also updated to reflect the changes.

class Censored
  DEFAULT_REPLACEMENT = ->(match) { '#' * match.to_s.length }

  def initialize(app, blacklist = [], replacement = DEFAULT_REPLACEMENT)
    @app = app
    @blacklist = Array(blacklist).map { |word| to_pattern(word) }
    @replacement = compile(replacement)
  end

  def call(env)
    status, headers, body = @app.call(env)
    body = body.map { |part|
      @blacklist.reduce(part) { |part, pattern| part.gsub(pattern, &@replacement) }
    }

    [status, headers, body]
  end

  private

  def to_pattern(word)
    return word if word.is_a? Regexp
    Regexp.new(Regexp.escape(word), Regexp::IGNORECASE)
  end

  def compile(replacement)
    replacement.is_a?(Proc) ? replacement : Proc.new { replacement }
  end
end
