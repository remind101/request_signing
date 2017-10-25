require 'test_helper'

class PlaintextAdapterTest < Test
  test "converts plaintext request to GenericHTTPRequest" do
    request = <<~HTTP
      POST /foo?param=value&pet=dog HTTP/1.1
      Host: example.com
      Date: Thu, 05 Jan 2014 21:31:40 GMT
      Content-Type: application/json
      Digest: SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=
      Content-Length: 18

      {"hello": "world"}
    HTTP

    generic_request = RequestSigning.get_adapter(:plaintext).call(request)
    expected_generic_request = RequestSigning::GenericHTTPRequest.new(
      "post",
      "/foo?param=value&pet=dog",
      "host" => ["example.com"],
      "date" => ["Thu, 05 Jan 2014 21:31:40 GMT"],
      "content-type" => ["application/json"],
      "digest" => ["SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="],
      "content-length" => ["18"]
    )

    assert_equal expected_generic_request, generic_request
  end
end
