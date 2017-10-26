require 'bundler/setup'
require 'request_signing'
require 'faraday'
require 'request_signing/faraday'

require 'net/http'
require 'optparse'
require 'time'
require 'uri'

options = {
  host:   "localhost",
  port:   4567,
  sign:   true,
  client: :net_http
}

SUPPORTED_CLIENTS = [:net_http, :faraday]

OptionParser.new do |opts|
  opts.banner = "example HTTP client"

  opts.on("-h", "--host HOST", "Example server host (default: localhost)") { |v| options[:host] = v }
  opts.on("-p", "--port PORT", Integer, "Example server port (default: 4567)") { |v| options[:port] = v }
  opts.on("-s", "--[no-]sign", "Whether the request should be signed (default: true)") { |v| options[:sign] = v }
  opts.on("-c", "--client CLIENT", SUPPORTED_CLIENTS, "which client should be used (net_http, faraday) (default: net_http)") { |v| options[:client] = v }
end.parse!

key_store = RequestSigning::KeyStores::Static.new(
  "client1.v1" => "uTj1izUmomtpECEhDfFb9lVDf54luNlH"
)

case options[:client]
when :net_http
  req = Net::HTTP::Get.new(URI("http://#{options[:host]}:#{options[:port]}/"))
  req["Date"] = Time.now.httpdate

  if options[:sign]
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
when :faraday
  conn = Faraday.new(url: "http://#{options[:host]}:#{options[:port]}") do |builder|
    if options[:sign]
      # note Faraday does not set the Host header, it is set downstream in in Net::HTTP::GenericRequest, but we can't use it in faraday itself.
      builder.request :request_signing, key_store: key_store, key_id: "client1.v1", algorithm: "hmac-sha256", headers: %w[(request-target) date]
    end
    builder.adapter :net_http
  end

  response = conn.get("/")
  puts response.body
else
  raise "Unsupported client: #{options[:client]}"
end

