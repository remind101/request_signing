require "request_signing/generic_http_request"

module RequestSigning
  module Adapters

    # Registers `:net_http` adapter for user with {RequestSigning::Signer}
    #
    # @example
    #   s = RequestSigning::Signer.new(adapter: :net_http, key_store: key_store)
    class NetHTTP
      def call(r)
        GenericHTTPRequest.new(
          r.method.downcase,
          r.path,
          r.each_header.map do |h, v|
            [h, Array(v)]
          end.to_h
        )
      end
    end

  end
end
