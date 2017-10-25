require 'test_helper'
require 'request_signing/rack'
require 'rack/mock'

class RackAdapterTest < Test
  test "converts rack request to GenericHTTPRequest" do
    request = Rack::MockRequest.env_for(
      "https://example.com/foo?param=value&pet=dog",
      method: "POST",
      input: %q[{"hello": "world"}],
      "CONTENT_TYPE" => "application/json",
      "CONTENT_LENGTH" => "18",
      "HTTP_DIGEST" => "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=",
      "HTTP_DATE" => "Thu, 05 Jan 2014 21:31:40 GMT",
      "HTTP_HOST" => "example.com"
    )

    generic_request = RequestSigning.get_adapter(:rack).call(request)
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

