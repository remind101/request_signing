require 'bundler/setup'
require 'sinatra'
require 'request_signing/rack'

class ExceptionHandling
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call env
    rescue RequestSigning::Error => e
      [401, { "Content-Type" => "text/plain" }, ["request signature verification error: #{e.message}"]]
    rescue => e
      [500, { "Content-Type" => "text/plain" }, ["unknown server error: #{e.message}"]]
    end
  end
end

key_store = RequestSigning::KeyStores::Static.new(
  "client1.v1" => "uTj1izUmomtpECEhDfFb9lVDf54luNlH"
)

use ExceptionHandling
use RequestSigning::Rack::Middleware, key_store: key_store

get "/" do
  "Request signature verified successfully!"
end
