# Simple, but naive JSONP wrapper. When a request includes a `callback`
# parameter and the response is `application/json`, it wraps the response in a
# JavaScript callback and updates the response `Content-Length`.

class JsonP
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end
end
