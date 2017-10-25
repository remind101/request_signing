require 'test_helper'
require 'request_signing/rack'
require 'rack/mock'

class RackMiddlewareTest < Test
  KEY_STORE = RequestSigning::KeyStores::Static.new(
    "rsa" => TEST_RSA_PUBKEY
  )

  def setup
    @app = Rack::Builder.new do
      use RequestSigning::Rack::Middleware, key_store: KEY_STORE

      run ->(env) { [200, {}, [%q({"success":"true"})]] }
    end
    @http = Rack::MockRequest.new(@app)
  end

  test "lets correctly signed requests through" do
    response = @http.get(
      "https://example.com/foo?param=value&pet=dog",
      method: "POST",
      input: %q({"hello": "world"}),
      "CONTENT_TYPE" => "application/json",
      "CONTENT_LENGTH" => "18",
      "HTTP_DATE" => "Thu, 05 Jan 2014 21:31:40 GMT",
      "HTTP_DIGEST" => "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=",
      "HTTP_AUTHORIZATION" => %q[Signature keyId="rsa",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="]
    )
    assert response.ok?, "correctly signed request should have succeeded"
  end

  test "raises request verification errors by default" do
    assert_raises(RequestSigning::SignatureMismatch) do
      @http.get(
        "https://example.com/foo?param=value&pet=dog",
        method: "POST",
        input: %q({"hello": "world"}),
        "CONTENT_TYPE" => "application/json",
        "CONTENT_LENGTH" => "18",
        "HTTP_DATE" => "Fri, 06 Jan 2017 22:11:20 GMT",
        "HTTP_DIGEST" => "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=",
        "HTTP_AUTHORIZATION" => %q[Signature keyId="rsa",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="]
      )
    end
  end

  test "optionally yields request signing errors if block is provided" do
    yielded_error = nil

    app = Rack::Builder.new do
      use RequestSigning::Rack::Middleware, key_store: KEY_STORE do |err, env, _app|
        yielded_error = err
        [401, { "Content-Type" => "application/json" }, [%q({"error": "bad signature"})]]
      end

      run ->(env) { [200, {}, [%q({"success":"true"})]] }
    end
    http = Rack::MockRequest.new(app)

    response = http.get(
      "https://example.com/foo?param=value&pet=dog",
      method: "POST",
      input: %q({"hello": "world"}),
      "CONTENT_TYPE" => "application/json",
      "CONTENT_LENGTH" => "18",
      "HTTP_DATE" => "Fri, 06 Jan 2017 22:11:20 GMT",
      "HTTP_DIGEST" => "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=",
      "HTTP_AUTHORIZATION" => %q[Signature keyId="rsa",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="]
    )

    assert_kind_of RequestSigning::Error, yielded_error
    assert_equal %q({"error": "bad signature"}), response.body
  end
end
