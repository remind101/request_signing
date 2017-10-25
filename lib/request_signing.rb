require "request_signing/version"
require "uri"
require "base64"
require "request_signing/generic_http_request"
require "request_signing/parameter_parser"
require "request_signing/adapters"
require "request_signing/algorithms"
require "request_signing/errors"
require "request_signing/key_stores"
require "request_signing/signature_parameters"

# @see RequestSigning::Signer
# @see RequestSigning::Verifier
module RequestSigning

  # Verifies the request signature
  #
  # @see RequestSigning::Rack
  class Verifier

    ##
    # @param adapter [Symbol] name of the library adapter.
    #   @see [RequestSigning::Adapters]
    # @param key_store [#fetch, #key?] signature verification key store
    #   @see [RequestSigning::KeyStores::Static]
    #
    # @raise [RequestSigning::UnsupportedAdapter] when the adapter is not registered
    ##
    def initialize(adapter:, key_store:)
      @adapter = RequestSigning.get_adapter(adapter)
      @key_store = key_store
    end

    ##
    # Verifies request signature
    #
    # @param req - an http request object from the library specified via :adapter
    #   @see [RequestSigning::Adapters]
    #
    # @raise [RequestSigning::SignatureMismatch] when the signature is invalid
    # @raise [RequestSigning::KeyNotFound] when the key store does not contain the key
    #   referenced in the request
    # @raise [RequestSigning::BadSignatureParameters] when the signature is malformed
    # @raise [RequestSigning::UnsupportedAlgorithm] when the algorithm referenced
    #   in the request is not supported
    # @raise [RequestSigning::InvalidKey] when the key in key store can not be used
    #   to verify the signature
    # @raise [RequestSigning::HeaderNotInRequest] when one of the headers specified
    #   in `headers` signature component is not present in the request
    # @raise [RequestSigning::MissingSignatureHeader] when neither `Signature` nor
    #   `Authorization` headers are present
    # @raise [RequestSigning::UnsupportedAuthorizationScheme] when the scheme
    #   specified in the `Authorization` header is not `Signature` and the `Signature`
    #   header is absent
    ##
    def verify!(req)
      verifiable_req = @adapter.call(req)
      signature_parameters = get_signature_parameters(verifiable_req)

      key = get_key(signature_parameters.key_id)
      alg = get_algorithm(signature_parameters.algorithm)
      string_for_signing = RequestSigning.make_string_for_signing(signature_parameters.headers, verifiable_req)
      signature = decode_signature(signature_parameters.signature)
      unless alg.verify_signature(key, signature, string_for_signing)
        raise SignatureMismatch
      end
    end

    private

    def get_signature_parameters(req)
      if req.header?("signature")
        parameters_str = req.headers["signature"].first
        ParameterParser.new.parse(parameters_str)
      elsif req.header?("authorization")
        auth_header = req.headers["authorization"].first
        auth_scheme, parameters_str = auth_header.split(" ", 2).map(&:strip)
        unless auth_scheme == "Signature"
          raise UnsupportedAuthorizationScheme, "Authorization header scheme must be 'Signature'"
        end
        ParameterParser.new.parse(parameters_str)
      else
        raise MissingSignatureHeader, "request must contain either Authorization or Signature header"
      end
    end

    def get_algorithm(name)
      RequestSigning.get_algorithm(name)
    end

    def get_key(id)
      @key_store.fetch(id)
    end

    def decode_signature(signature_base64)
      Base64.strict_decode64(signature_base64)
    rescue ArgumentError
      raise BadSignatureParameters, "malformed signature"
    end
  end

  ##
  # Creates request signature string
  #
  # @example
  #   key_store = RequestSigning::KeyStores::Static.new(
  #     "app_1.v1" => ENV["APP_1_PRIVATE_KEY"],
  #     "app_2.v1" => ENV["APP_2_PRIVATE_KEY"],
  #   )
  #   req = Net::HTTP::Get.new("/foo?bar=baz")
  #   req["Date"] = "Thu, 05 Jan 2014 21:31:40 GMT"
  #   req["Signature"] =
  #     @signer.create_signature!(req, key_id: "app_1.v1", algorithm: "rsa-sha256", headers: %w[(request-target) date host])
  #   Net::HTTP.start("http://example.com", 80) do |http|
  #     response = http.request(req)
  #   end
  ##
  class Signer
    ##
    # @param adapter [Symbol] name of the library adapter.
    #   @see [RequestSigning::Adapters]
    # @param key_store [#fetch, #key?] signature verification key store
    #   @see [RequestSigning::KeyStores::Static]
    #
    # @raise [RequestSigning::UnsupportedAdapter] when the adapter is not registered
    ##
    def initialize(adapter:, key_store:)
      @adapter = RequestSigning.get_adapter(adapter)
      @key_store = key_store
    end

    ##
    # Creates a signature string
    #
    # @example
    #   keyId="hmac",algorithm="hmac-sha256",headers="date",signature="id0KmonZJTY53n+fk27Q5CtroeQ5UyRY/tbotiuhob4="
    #
    # @param req an http request object from the library specified via :adapter; see {RequestSigning::Adapters}
    # @param key_id [String] key id to use for signing
    # @param algorithm [String] algorithm to use for signing, e.g. `"rsa-sha256"`
    # @param headers [Array<String>] headers to sign
    #
    #   May include special `(request-target)` header.
    #
    #   The recommendation is to sign:
    #   - for HTTPS requests - `["(request-target"), "host", "date"]`
    #   - for HTTP requests - all headers
    #
    #   See {https://tools.ietf.org/html/draft-cavage-http-signatures-08#section-2.3}
    #
    # @return [String] signature components string. See example above.
    #
    # @raise [RequestSigning::KeyNotFound] when the key store does not contain the key
    #   referenced in the :key_id parameter
    # @raise [RequestSigning::UnsupportedAlgorithm] when the algorithm referenced
    #   in :algorithm parameter is not supported
    # @raise [RequestSigning::InvalidKey] when the key in key store can not be used
    #   to create the signature
    # @raise [RequestSigning::HeaderNotInRequest] when one of the headers specified
    #   in `headers` signature component is not present in the request
    ##
    def create_signature!(req, key_id:, algorithm:, headers: %w[date])
      signable_req = @adapter.call(req)

      headers = normalize_headers(headers)
      key = get_key(key_id)
      alg = get_algorithm(algorithm)
      string_for_signing = RequestSigning.make_string_for_signing(headers, signable_req)
      signature = alg.create_signature(key, string_for_signing)
      SignatureParameters.new(
        key_id:    key_id,
        algorithm: algorithm,
        headers:   headers,
        signature: encode_signature(signature)
      )
    end

    private

    def get_algorithm(name)
      RequestSigning.get_algorithm(name)
    end

    def get_key(id)
      @key_store.fetch(id)
    end

    def encode_signature(signature)
      Base64.strict_encode64(signature).chomp
    end

    def normalize_headers(headers)
      headers.map(&:downcase)
    end
  end

  # @api private
  def self.make_string_for_signing(headers_list, verifiable_req)
    headers_list.each_with_object([]) do |h, a|
      case h
      when "(request-target)"
        a << "(request-target): #{verifiable_req.method.downcase} #{verifiable_req.path}"
      else
        vs = Array(verifiable_req.headers[h])
        if vs.empty?
          raise HeaderNotInRequest, h
        end
        a << "#{h}: #{vs.join(", ").strip}"
      end
    end.join("\n")
  end
end
