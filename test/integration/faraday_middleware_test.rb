require 'test_helper'
require 'request_signing/faraday'

class FaradayMiddlewareTest < Test
  def setup
    @key_store = RequestSigning::KeyStores::Static.new(
      "rsa" => TEST_RSA_PRIVATE_KEY
    )
  end

  test "signs the request" do
    signature = nil
    connection = make_connection(key_id: "rsa", algorithm: "rsa-sha256", headers: %w[(request-target) date x-my-header]) do |stub|
      stub.post("/foo") { |env| signature = env.request_headers["Signature"] }
    end
    connection.post("/foo?bar=baz") do |req|
      req.headers["date"] = "Thu, 05 Jan 2014 21:31:40 GMT"
      req.headers["x-my-header"] = "test"
    end

    expected_signature =
      begin
        signer = RequestSigning::Signer.new(adapter: :plaintext, key_store: @key_store)
        request = <<~HTTP
          POST /foo?bar=baz HTTP/1.1
          Host: example.com
          Date: Thu, 05 Jan 2014 21:31:40 GMT
          X-My-Header: test

          {"hello": "world"}
        HTTP
        signer.create_signature!(request, key_id: "rsa", algorithm: "rsa-sha256", headers: %w[(request-target) date x-my-header]).to_s
      end

    assert_equal expected_signature, signature
  end

  test "raises KeyNotFound on missing signing key" do
    connection = make_connection(key_id: "wat", algorithm: "rsa-sha256", headers: %w[(request-target) date x-my-header])
    err = assert_raises(RequestSigning::KeyNotFound) do
      connection.get("/")
    end
    assert_match(/wat/, err.message)
  end

  test "raises UnsupportedAlgorithm for unknown algorithms" do
    connection = make_connection(key_id: "rsa", algorithm: "wat", headers: %w[(request-target) date x-my-header])
    err = assert_raises(RequestSigning::UnsupportedAlgorithm) do
      connection.get("/")
    end
    assert_match(/wat/, err.message)
  end

  test "raises InvalidKey for bad signing keys" do
    @key_store = RequestSigning::KeyStores::Static.new("rsa" => "WAT")
    connection = make_connection(key_id: "rsa", algorithm: "rsa-sha256", headers: %w[(request-target) date])
    assert_raises(RequestSigning::InvalidKey) do
      connection.get("/")
    end
  end

  test "raises HeaderNotInRequest when one of specified headers is missing from the request" do
    connection = make_connection(key_id: "rsa", algorithm: "rsa-sha256", headers: %w[(request-target) date x-my-header])
    err = assert_raises(RequestSigning::HeaderNotInRequest) do
      connection.get("/")
    end
    assert_match(/x-my-header/, err.message)
  end

  def make_connection(**kwargs, &block)
    block ||= proc do |stub|
      stub.get("/") {}
    end

    Faraday.new do |builder|
      builder.request :request_signing, key_store: @key_store, **kwargs
      builder.adapter :test, &block
    end
  end
end

