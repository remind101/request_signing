require "webrick/httputils"

module RequestSigning

  # @api private
  class SignatureParameters
    attr_reader :key_id, :algorithm, :headers, :signature

    def initialize(key_id:, algorithm:, headers:, signature:)
      @key_id = key_id
      @algorithm = algorithm
      @headers = headers
      @signature = signature
    end

    def to_s
      "keyId=#{quote(key_id)},algorithm=#{quote(algorithm)},headers=#{quote(headers_str)},signature=#{quote(signature)}"
    end

    private

    def quote(str)
      WEBrick::HTTPUtils.quote(str)
    end

    def headers_str
      headers.join(" ")
    end
  end

end
