# More of a fun middleware to demonstrate something that modifies the response
# from a downstream app. A black list of words is passed to the initializer and
# it then replaces any instances of a word with REDACTED. The `Content-Length`
# of the response is also updated to reflect the changes.

class Censored
  def initialize(app, blacklist = [])
    @app = app
    @blacklist = blacklist
  end

  def call(env)
    status, headers, body = @app.call(env)
    body = body.map { |part|
      @blacklist.reduce(part) { |part, word|
        replacement = '#' * word.length
        part.gsub(word, replacement)
      }
    }

    [status, headers, body]
  end
end
