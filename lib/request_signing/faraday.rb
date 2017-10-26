require 'faraday'
require "request_signing"

module RequestSigning
  module Adapters

    # Registers `:faraday` adapter for user with {RequestSigning::Signer}
    #
    # @example
    #   v = RequestSigning::Signer.new(adapter: :faraday, key_store: key_store)
    class Faraday
      def call(faraday_env)
        GenericHTTPRequest.new(
          faraday_env.method.to_s,
          faraday_env.url.request_uri,
          faraday_env.request_headers.map do |h, v|
            [h.downcase, Array(v)]
          end
        )
      end
    end
  end
  register_adapter :faraday, ->() { Adapters::Faraday.new }

  module Faraday

    ##
    # Provides faraday request middleware for request signing
    #
    # @example
    #   key_store = RequestSigning::KeyStores::Static.new(
    #     "app_1.v1" => ENV["APP_1_SECRET"],
    #     "app_2.v1" => ENV["APP_2_SECRET"],
    #   )
    #   conn = Faraday.new(url: "http://example.com") do |builder|
    #     builder.request :request_signing, key_store: key_store, key_id: "app_1.v1", algorithm: "hmac-sha256", headers: %w[(request-target) date x-user-id]
    #     builder.adapter :net_http
    #   end
    #
    #   conn.post("/foo") do |req|
    #     req.headers["x-user-id"] = "42"
    #   end
    ##
    class Middleware  < ::Faraday::Middleware

      ##
      # @param key_store (see RequestSigning::Signer#initialize)
      # @param key_id (see RequestSigning::Signer#create_signature!)
      # @param algorithm (see RequestSigning::Signer#create_signature!)
      # @param headers (see RequestSigning::Signer#create_signature!)
      # @raise (see RequestSigning::Signer#create_signature!)
      ##
      def initialize(app, key_store:, key_id:, algorithm: , headers: %w[date])
        super(app)
        @key_id = key_id
        @algorithm = algorithm
        @headers = headers
        @signer = RequestSigning::Signer.new(adapter: :faraday, key_store: key_store)
      end

      def call(env)
        env.request_headers["Date"] ||= Time.now.httpdate
        env.request_headers["Signature"] = @signer.create_signature!(env, key_id: @key_id, algorithm: @algorithm, headers: @headers).to_s
        @app.call(env)
      end
    end
  end
end

Faraday::Request.register_middleware :request_signing => RequestSigning::Faraday::Middleware
