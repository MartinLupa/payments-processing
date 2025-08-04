require 'json'

class ErrorHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue StandardError => e
    warn "[ERROR] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    [
      500,
      { 'content-type' => 'application/json' },
      [{ data: nil, error: 'Internal Server Error' }.to_json]
    ]
  end
end
