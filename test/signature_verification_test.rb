require 'test_helper'

class SignatureVerificationTest < Test
  def setup
    @key_store = RequestSigning::KeyStores::Static.new(
      "rsa"  => TEST_RSA_PUBKEY,
      "dsa"  => TEST_DSA_PUBKEY,
      "hmac" => TEST_HMAC_SECRET
    )
    @verifier = RequestSigning::Verifier.new(adapter: :plaintext, key_store: @key_store)
  end

  test "verifies request signature from Signature header" do
    req = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18
      Signature: keyId="rsa",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="

      {"hello": "world"}
    HTTP

    @verifier.verify!(req)
  end

  test "verifies request signature from Authorization header with Signature authorization scheme" do
    req = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18
      Authorization: Signature keyId="rsa",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="

      {"hello": "world"}
    HTTP

    @verifier.verify!(req)
  end

  test "supports multiple algorithms" do
    [
      ["rsa-sha1",    "rsa",  "Xrq3ADMzjG+MGvRo93uQTQk9o+9X9aHpVtAPmYiYAVJDGBxAA1JPaaSfzvSud6GOQ3Bm6uikWx4Uca7jcvq13X3PjAz7xrjyYGk6Mwnq0gXqWA11NwPW2dHIf9/tlpx8UzrO2I65h1bP+H6xHzrrcn8+5y2cZHcg2IucLwRjYoY="],
      ["rsa-sha256",  "rsa",  "jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="],
      ["rsa-sha512",  "rsa",  "QM2kn0gZSMenAJfFW8yaN32Ft1hFSppYJgFmzh9tUqrMvPweBA6tj2k2ENrLYX0AK3x7usHhxyF14g1FyQt5w+8PeyawUNehbyCcqGys4xsdEjzmxGvxOAU/eD3RgPtSF5VZS+CE8IM1bXJKxGly++A/loSm3vSbArCfH2tIV+8="],
      ["dsa-sha1",    "dsa",  "MC0CFHtcXH8ZPCZZnAuwFv1/tu0cDvwcAhUAkq3cRD5FgjuykwfwgO2S6vcMmXw="],
      ["hmac-sha1",   "hmac", "h5g8YbV0ZgC2ZM/kpeS2UT0PIqg="],
      ["hmac-sha256", "hmac", "id0KmonZJTY53n+fk27Q5CtroeQ5UyRY/tbotiuhob4="],
      ["hmac-sha512", "hmac", "LDIsoWYa5SxIXgXDVksyzA8GbkRjtje7wLamPJf1iYcJAdLsnDSxpgzzxsqj2weKCNk5hyFr4aO90SMCG8xnpA=="],
    ].each do |algorithm, key_id, signature|
      req = <<~HTTP
        POST /foo?param=value&pet=dog HTTP/1.1
        Host: example.com
        Date: Thu, 05 Jan 2014 21:31:40 GMT
        Content-Type: application/json
        Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
        Content-Length: 18
        Authorization: Signature keyId="#{key_id}",algorithm="#{algorithm}",signature="#{signature}"

        {"hello": "world"}
      HTTP

      @verifier.verify!(req) rescue raise $!, "#{algorithm} verification failed!: #{$!}", $!.backtrace
    end
  end

  test "raises on tampered signature" do
    req = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18
      Signature: keyId="rsa",algorithm="rsa-sha256",signature="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="

      {"hello": "world"}
    HTTP

    assert_raises(RequestSigning::SignatureMismatch) do
      @verifier.verify!(req)
    end
  end

  test "raises on invalid signature" do
    req = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18
      Signature: keyId="rsa",algorithm="rsa-sha256",signature="??not$#%base64"

      {"hello": "world"}
    HTTP

    assert_raises(RequestSigning::BadSignatureParameters) do
      @verifier.verify!(req)
    end
  end

  test "raises on missing headers" do
    req = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18
      Signature: keyId="rsa",algorithm="rsa-sha256",headers="(request-target) x-user-uuid",signature="signature"

      {"hello": "world"}
    HTTP

    err = assert_raises(RequestSigning::HeaderNotInRequest) do
      @verifier.verify!(req)
    end
    assert_match(/x-user-uuid/, err.message)
  end
end
