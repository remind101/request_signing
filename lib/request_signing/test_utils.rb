module RequestSigning
  module TestUtils
    # Provides helpers for testing request signature verification integration
    # Example:
    #   require 'rack/test'
    #   require 'request_signing'
    #   require 'request_signing/test_utils'
    #
    #   class MyServerTest < Minitest::Test
    #     include Rack::Test::Methods
    #     include RequestSigning::TestUtils::Rack
    #
    #     attr_reader :app
    #
    #     def setup
    #       my_app = MyApp.new
    #       signer_key_store = RequestSigning::KeyStores::Static.new(
    #         "test_key"     => "123qweasdzxc456rtyfghvbn789uiojk",
    #         "bad_test_key" => "11111111111111111111111111111111"
    #       )
    #       signer = RequestSigning::Signer.new(adapter: :rack, key_store: signer_key_store)
    #       @app = wrap_with_request_signer(app: my_app, signer: signer)
    #     end
    #
    #     def test_lets_signed_requests_through
    #       signed(key_id: "test_key") { post "/v1/foo" }
    #       assert last_response.successful?
    #     end
    #
    #     def test_rejects_requests_with_bad_signatures
    #       signed(key_id: "bad_test_key") { post "/v1/foo" }
    #       refute last_response.successful?
    #     end
    #
    module Rack
      def wrap_with_request_signer(signer:, app:)
        proc do |env|
          if sign_params = env["request_signing.test.sign_params"]
            env["HTTP_DATE"] ||= Time.now.httpdate
            env["HTTP_SIGNATURE"] = signer.create_signature!(env, sign_params).to_s
          end
          app.call(env)
        end
      end

      def signed(key_id:, algorithm: "hmac-sha256", headers: %w[(request-target) host date])
        env "request_signing.test.sign_params", { key_id: key_id, algorithm: algorithm, headers: headers }
        yield
      ensure
        env "request_signing.test.sign_params", nil
      end
    end
  end
end

