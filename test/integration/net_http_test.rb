require 'test_helper'
require 'request_signing'
require 'net/http'

class NetHTTPIntegrationTest < Test
  KEY_STORE = RequestSigning::KeyStores::Static.new(
    "rsa" => TEST_RSA_PRIVATE_KEY
  )

  def setup
    @signer = RequestSigning::Signer.new(adapter: :net_http, key_store: KEY_STORE)
  end

  test "can sign net http request" do
    req = Net::HTTP::Get.new(URI("http://example.com/foo?bar=baz"))
    req["Date"] = "Thu, 05 Jan 2014 21:31:40 GMT"
    req["Signature"] = @signer.create_signature!(req, key_id: "rsa", algorithm: "rsa-sha256", headers: %w[(request-target) date host])
  end
end

