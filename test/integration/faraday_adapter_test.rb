require 'test_helper'
require 'request_signing/faraday'

class FaradayAdapterTest < Test
  test "converts faraday request to GenericHTTPRequest" do
    request = Faraday.default_connection.build_request(:post) do |r|
      r.url "https://example.com/foo", "param" => "value", "pet" => "dog"
      r.headers["User-Agent"] = "Faraday"
      r.headers["Digest"] = "SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="
      r.headers["Date"] = "Thu, 05 Jan 2014 21:31:40 GMT"
      r.headers["Content-Type"] = "application/json"
      r.headers["Content-Length"] = "18"
      r.body = %q({"hello": "world"})
    end.to_env(Faraday.default_connection)

    generic_request = RequestSigning.get_adapter(:faraday).call(request)
    expected_generic_request = RequestSigning::GenericHTTPRequest.new(
      "post",
      "/foo?param=value&pet=dog",
      "date" => ["Thu, 05 Jan 2014 21:31:40 GMT"],
      "content-type" => ["application/json"],
      "digest" => ["SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="],
      "content-length" => ["18"],
      "user-agent" => ["Faraday"],
    )

    assert_equal expected_generic_request, generic_request
  end
end
