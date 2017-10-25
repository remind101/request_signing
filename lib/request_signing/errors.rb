module RequestSigning

  # Base class for all errors
  class Error < StandardError; end

  # Key with specified keyId could not be found
  class KeyNotFound < Error; end

  # Provided signature does not match the request
  class SignatureMismatch < Error; end

  # Signature/Authorization header is malformed
  class BadSignatureParameters < Error; end

  # Signing algorithm is not supported
  class UnsupportedAlgorithm < Error; end

  # Library is not supported
  class UnsupportedAdapter < Error; end

  # Key can not be used to create/verify the signature by the given algorithm
  class InvalidKey < Error; end

  # Header specified in `headers` parameter for signature is
  # not present in the request
  class HeaderNotInRequest < Error; end

  # Signature/Authorization header are missing from the request
  class MissingSignatureHeader < Error; end

  # Authorization header scheme is incorrect. It must be "Signature"
  class UnsupportedAuthorizationScheme < Error; end

  # Keys string provided to {RequestSigning::KeyStores::Static#from_string} is not valid
  class MalformedKeysString < Error; end

end
