require "webrick/httprequest"
require "webrick/config"
require "stringio"

require "request_signing/generic_http_request"

module RequestSigning
  module Adapters

    # @api private
    class Plaintext
      def call(plaintext_http)
        webrick_req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
        webrick_req.parse(StringIO.new(plaintext_http))

        GenericHTTPRequest.new(
          webrick_req.request_method.downcase,
          webrick_req.request_uri.request_uri,
          webrick_req.header
        )
      end
    end

  end
end

