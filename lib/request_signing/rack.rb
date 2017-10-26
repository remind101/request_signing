require "rack/request"
require "request_signing"

module RequestSigning
  module Adapters

    # Registers `:rack` adapter for user with {RequestSigning::Verifier}
    #
    # @example
    #   v = RequestSigning::Verifier.new(adapter: :rack, key_store: key_store)
    class Rack
      def call(rack_request_env)
        rack_request = ::Rack::Request.new(rack_request_env)
        headers =
          rack_request.each_header.select do |h, _|
            h.start_with?("HTTP_") || %w[CONTENT_TYPE CONTENT_LENGTH].include?(h)
          end.map do |h, v|
            [h.gsub(/\AHTTP_/, "").gsub(/_/, "-").downcase, Array(v)]
          end.to_h

        GenericHTTPRequest.new(
          rack_request.request_method.downcase,
          rack_request.fullpath,
          headers
        )
      end
    end
  end
  register_adapter :rack, ->() { Adapters::Rack.new }

  module Rack

    ##
    # Provides rack middleware for request signature verification
    #
    # @example common use case
    #   key_store = RequestSigning::KeyStores::Static.new(
    #     "app_1.v1" => ENV["APP_1_PUBKEY"],
    #     "app_2.v1" => ENV["APP_2_PUBKEY"],
    #   )
    #   use RequestSigning::Rack::Middleware, key_store: key_store
    #
    # @example custom error handling
    #   key_store = RequestSigning::KeyStores::Static.new(
    #     "app_1.v1" => ENV["APP_1_PUBKEY"],
    #     "app_2.v1" => ENV["APP_2_PUBKEY"],
    #   )
    #   logger = Logger.new(STDOUT)
    #
    #   use RequestSigning::Rack::Middleware, key_store: key_store do |error, env, app|
    #     case error
    #     when RequestSigning::KeyNotFound, RequestSigning::MissingSignatureHeader
    #       # Useful during transition period while some clients still don't sign requests
    #       logger.debug("skipping signature verification: #{error}")
    #       app.call(env)
    #     else
    #       logger.error(error)
    #       [401, { "Content-Type" => "application/json" }, [%q({"error": "signature verification error"})]]
    #     end
    #   end
    ##
    class Middleware
      ##
      # @overload initialize(app, key_store:)
      #   @param app [#call] underlying rack app
      #   @param key_store [#fetch, #key?] verification key repository
      #   @raise [RequestSigning::Error] request signature verification error
      #
      # @overload initialize(app, key_store:)
      #   @param app [#call] underlying rack app
      #   @param key_store [#fetch, #key?] verification key repository
      #   @yieldparam err [RequestSigning::Error] signature verification error object
      #   @yieldparam env [Rack::Request::Env] rack request
      #   @yieldparam app [#call] the underlying rack app
      ##
      def initialize(app, key_store:, &block)
        @app = app
        @verifier = RequestSigning::Verifier.new(adapter: :rack, key_store: key_store)
        @block = block || proc { |err, _, _| raise err if err }
      end

      def call(env)
        @verifier.verify!(env)
        @app.call(env)
      rescue RequestSigning::Error => e
        @block.call(e, env, @app)
      end
    end
  end
end
