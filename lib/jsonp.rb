# Simple, but naive JSONP wrapper. When a request includes a `callback`
# parameter and the response is `application/json`, it wraps the response in a
# JavaScript callback and updates the response `Content-Length`.

class JsonP
  APPLICATION_JSON = %r{application/json}

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    status, headers, body = @app.call(env)

    callback_name = request.params['callback']
    content_type = headers['Content-Type']

    if callback_name && content_type =~ APPLICATION_JSON
      body = apply_padding(body, callback_name)
      headers['Content-Length'] = content_length(body)
    end

    [status, headers, body]
  end

  def _call(env)
    status, headers, body = @app.call(env)

    request = Rack::Request.new(env)
    if callback_name = request.params['callback']
      body = apply_padding(body, callback_name)
      headers['Content-Length'] = content_length(body)
    end

    [status, headers, body]
  end

  def apply_padding(body, callback_name)
    body.map { |str| "#{callback_name}(#{str});" }
  end

  def content_length(body)
    body.reduce(0) { |len, part| len += part.length }.to_s
  end
end
