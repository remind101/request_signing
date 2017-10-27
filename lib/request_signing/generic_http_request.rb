module RequestSigning

  # @api private
  class GenericHTTPRequest
    attr_reader :method, :headers

    # HTTP/1.1 request methods
    # @see https://tools.ietf.org/html/rfc7231#section-4.1
    HTTP_METHODS = %w(get head post put delete connect options trace patch).freeze

    # @api public
    # @param method [String] HTTP request method
    # @param request_uri [URI] part of request url after host and port, e.g. "/foo?bar=baz"
    # @param headers [Hash{String=>Array<String>}] hash of lowercased request headers,
    #   e.g. { "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"] }
    def initialize(method, request_uri, headers)
      method = method.downcase

      unless HTTP_METHODS.include?(method)
        raise ArgumentError, "Invalid HTTP method"
      end

      @method = method
      @request_uri = URI(request_uri)
      @headers = Hash[headers].freeze
    end


    # :path pseudo-header
    # @see https://tools.ietf.org/html/rfc7540#section-8.1.2.3
    def path
      @request_uri.to_s
    end

    def header?(name)
      @headers.key?(name)
    end

    def ==(other)
      return false unless self.class === other
      method == other.method &&
        path == other.path &&
        headers == other.headers
    end
  end

end
