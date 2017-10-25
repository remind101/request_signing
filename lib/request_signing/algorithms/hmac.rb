require "openssl"

module RequestSigning
  module Algorithms

    class HMAC
      # @param digester [OpenSSL::Digest]
      def initialize(digester)
        @digester = digester
      end

      # @param hmac_secret [String] HMAC signing secret; 32-byte secret is recommended
      # @param str [String] string to sign
      # @raise [InvalidKey] when invalid HMAC signing secret is supplied
      def create_signature(hmac_secret, str)
        raise InvalidKey, "HMAC secret cannot be empty" if String(hmac_secret).empty?

        OpenSSL::HMAC.digest(@digester, hmac_secret, str)
      end

      # @param hmac_secret [String] HMAC signing secret; 32-byte secret is recommended
      # @param signature [String] signature to verify
      # @param str [String] signed string
      # @raise [InvalidKey] when invalid HMAC signing secret is supplied
      # @return true if signature is valid
      # @return false if signature is invalid
      def verify_signature(hmac_secret, signature, str)
        raise InvalidKey, "HMAC secret cannot be empty" if String(hmac_secret).empty?

        recreated_signature = OpenSSL::HMAC.digest(@digester, hmac_secret, str)
        signature == recreated_signature
      end
    end

  end
end

