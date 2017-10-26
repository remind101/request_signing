require 'bundler/setup'
require 'request_signing'

require 'net/http'
require 'optparse'
require 'time'
require 'uri'

options = {
  host: "localhost",
  port: 4567,
  sign: true
}

OptionParser.new do |opts|
  opts.banner = "example HTTP client"

  opts.on("-h", "--host HOST", "Example server host (default: localhost)") { |v| options[:host] = v }
  opts.on("-p", "--port PORT", Integer, "Example server port (default: 4567)") { |v| options[:port] = v }
  opts.on("-s", "--[no]-sign", "Whether the request should be signed (default: true)") { |v| options[:sign] = v }
end.parse!

req = Net::HTTP::Get.new(URI("http://#{options[:host]}:#{options[:port]}/"))
req["Date"] = Time.now.httpdate

if options[:sign]
  key_store = RequestSigning::KeyStores::Static.new(
    "client1.v1" => "uTj1izUmomtpECEhDfFb9lVDf54luNlH"
  )
  signer = RequestSigning::Signer.new(adapter: :net_http, key_store: key_store)
  req["Signature"] =
    signer.create_signature!(req, key_id: "client1.v1", algorithm: "hmac-sha256", headers: %w[(request-target) host date])
end


http = Net::HTTP.new(options[:host], options[:port])
http.set_debug_output(STDERR)
http.start do
  response = http.request req
  puts response.body
end

