require 'test_helper'

class NetHTTPAdapterTest < Test
  test "converts Net::HTTPRequest to GenericHTTPRequest" do
    request = Net::HTTP::Post.new(URI("https://example.com/foo?param=value&pet=dog"))
    request.body = %q({"hello": "world"})
    request["Content-Type"] = "application/json"
    request["Content-Length"] = "18"
    request["Digest"] = "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="
    request["Date"] = "Thu, 05 Jan 2014 21:31:40 GMT"

    generic_request = RequestSigning.get_adapter(:net_http).call(request)
    expected_generic_request = RequestSigning::GenericHTTPRequest.new(
      "post",
      "/foo?param=value&pet=dog",
      "host" => ["example.com"],
      "date" => ["Thu, 05 Jan 2014 21:31:40 GMT"],
      "content-type" => ["application/json"],
      "digest" => ["SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="],
      "content-length" => ["18"],
      "accept" => ["*/*"],
      "user-agent" => ["Ruby"],
      "accept-encoding" => ["gzip;q=1.0,deflate;q=0.6,identity;q=0.3"],
    )

    assert_equal expected_generic_request, generic_request
  end
end
