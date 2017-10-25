module RequestSigning

  ##
  # Contains adapters for various http libraries.
  # Adapters are used by {RequestSigning::Signer} and {RequestSigning::Verifier} to
  # convert library specific http request objects to a common format.
  #
  # @example Adding new adapter
  #
  #   require 'request_signing'
  #
  #   class MyAdapter
  #     def call(my_http_library_req)
  #       RequestSigning::GenericHTTPRequest.new(
  #         my_http_library_req.request_method.downcase,
  #         my_http_library_req.request_full_path,
  #         my_http_library_req.headers.map do |h, v|
  #           [h, Array(v)]
  #         end.to_h
  #       )
  #     end
  #   end
  #
  #   RequestSigning.register_adapter :my_http_library, ->() { MyAdapter.new }
  #
  #   # ...
  #
  #   req = MyHTTPLibrary::Post("/foo?bar=baz", "Date" => "Mon, 23 Oct 2017 00:00:00 GMT")
  #   signer = RequestSigning::Signer.new(adapter: :my_http_library, key_store: key_store)
  #   req.set_header "Signature", signer.create_signature!(req, key_id: "my_key", algorithm: "rsa-sha256", headers: %w[(request-target) date])
  #
  #   # ...
  #
  # @see RequestSigning::GenericHTTPRequest#initialize
  ##
  module Adapters
    require "request_signing/adapters/plaintext"
    require "request_signing/adapters/net_http"
  end

  @adapters = {}

  def self.get_adapter(name)
    @adapters.fetch(name).call
  rescue KeyError
    raise UnsupportedAdapter, name
  end

  def self.register_adapter(name, adapter_factory)
    @adapters[name] = adapter_factory
  end

  register_adapter :plaintext, ->() { Adapters::Plaintext.new }
  register_adapter :net_http,  ->() { Adapters::NetHTTP.new }

end
