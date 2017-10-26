require 'test_helper'

class SigningTest < Test
  def setup
    @key_store = RequestSigning::KeyStores::Static.new(
      "rsa"  => TEST_RSA_PRIVATE_KEY,
      "dsa"  => TEST_DSA_PRIVATE_KEY,
      "hmac" => TEST_HMAC_SECRET
    )
    @signer = RequestSigning::Signer.new(adapter: :plaintext, key_store: @key_store)

    @sample_request = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18

      {"hello": "world"}
    HTTP
  end

  test "makes a signature" do
    [
      { key_id: "rsa", algorithm: "rsa-sha1", headers: %w[date], result: %q[keyId="rsa",algorithm="rsa-sha1",headers="date",signature="Xrq3ADMzjG+MGvRo93uQTQk9o+9X9aHpVtAPmYiYAVJDGBxAA1JPaaSfzvSud6GOQ3Bm6uikWx4Uca7jcvq13X3PjAz7xrjyYGk6Mwnq0gXqWA11NwPW2dHIf9/tlpx8UzrO2I65h1bP+H6xHzrrcn8+5y2cZHcg2IucLwRjYoY="] },
      { key_id: "rsa", algorithm: "rsa-sha256", headers: %w[date], result: %q[keyId="rsa",algorithm="rsa-sha256",headers="date",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="] },
      { key_id: "rsa", algorithm: "rsa-sha512", headers: %w[date], result: %q[keyId="rsa",algorithm="rsa-sha512",headers="date",signature="QM2kn0gZSMenAJfFW8yaN32Ft1hFSppYJgFmzh9tUqrMvPweBA6tj2k2ENrLYX0AK3x7usHhxyF14g1FyQt5w+8PeyawUNehbyCcqGys4xsdEjzmxGvxOAU/eD3RgPtSF5VZS+CE8IM1bXJKxGly++A/loSm3vSbArCfH2tIV+8="] },
      { key_id: "hmac", algorithm: "hmac-sha1", headers: %w[date], result: %q[keyId="hmac",algorithm="hmac-sha1",headers="date",signature="h5g8YbV0ZgC2ZM/kpeS2UT0PIqg="] },
      { key_id: "hmac", algorithm: "hmac-sha256", headers: %w[date], result: %q[keyId="hmac",algorithm="hmac-sha256",headers="date",signature="id0KmonZJTY53n+fk27Q5CtroeQ5UyRY/tbotiuhob4="] },
      { key_id: "hmac", algorithm: "hmac-sha512", headers: %w[date], result: %q[keyId="hmac",algorithm="hmac-sha512",headers="date",signature="LDIsoWYa5SxIXgXDVksyzA8GbkRjtje7wLamPJf1iYcJAdLsnDSxpgzzxsqj2weKCNk5hyFr4aO90SMCG8xnpA=="] },
    ].each do |key_id:, algorithm:, headers:, result:|
      signature = @signer.create_signature!(@sample_request, key_id: key_id, algorithm: algorithm, headers: headers).to_s
      assert_equal result, signature, algorithm
    end

    signature = @signer.create_signature!(@sample_request, key_id: "dsa", algorithm: "dsa-sha1", headers: %w[date])
    adapter = RequestSigning::Adapters::Plaintext.new
    raw_signature = Base64.strict_decode64(signature.signature)
    signing_string = RequestSigning.make_string_for_signing(%w[date], adapter.call(@sample_request))
    RequestSigning.get_algorithm("dsa-sha1").verify_signature(TEST_DSA_PUBKEY, raw_signature, signing_string)
  end

  test "ignores header case" do
    signature1 = @signer.create_signature!(@sample_request, key_id: "hmac", algorithm: "hmac-sha256", headers: %w[Date cOnTEnt-typE]).to_s
    signature2 = @signer.create_signature!(@sample_request, key_id: "hmac", algorithm: "hmac-sha256", headers: %w[date content-type]).to_s
    assert_equal signature1, signature2
  end

  test "raises when key is absent" do
    err = assert_raises(RequestSigning::KeyNotFound) do
      @signer.create_signature!(@sample_request, key_id: "bad_key", algorithm: "hmac-sha256", headers: %w[date])
    end
    assert_match(/bad_key/, err.message)
  end

  test "raises when specified header is absent from the request" do
    err = assert_raises(RequestSigning::HeaderNotInRequest) do
      @signer.create_signature!(@sample_request, key_id: "hmac", algorithm: "hmac-sha256", headers: %w[date x-user-uuid])
    end
    assert_match(/x-user-uuid/, err.message)
  end

  test "signs using `date` header by default" do
    signature1 = @signer.create_signature!(@sample_request, key_id: "hmac", algorithm: "hmac-sha256", headers: %w[date]).to_s
    signature2 = @signer.create_signature!(@sample_request, key_id: "hmac", algorithm: "hmac-sha256").to_s
    assert_equal signature1, signature2
  end
end

