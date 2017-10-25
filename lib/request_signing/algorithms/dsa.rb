require "openssl"

module RequestSigning
  module Algorithms

    class DSA
      # @param digester [OpenSSL::Digest]
      def initialize(digester)
        @digester = digester
      end

      # @param raw_private_key [String] DSA private key
      # @param str [String] string to sign
      # @raise [InvalidKey] when invalid DSA private key is supplied
      def create_signature(raw_private_key, str)
        key = OpenSSL::PKey::DSA.new(raw_private_key)
        key.sign(@digester, str)
      rescue OpenSSL::PKey::DSAError => e
        raise InvalidKey, e
      end

      # @param raw_public_key [String] DSA public key
      # @param signature [String] signature to verify
      # @param str [String] signed string
      # @raise [InvalidKey] when invalid DSA public key is supplied
      # @return true if signature is valid
      # @return false if signature is invalid
      def verify_signature(raw_public_key, signature, str)
        key = OpenSSL::PKey::DSA.new(raw_public_key)
        key.verify(@digester, signature, str)
      rescue OpenSSL::PKey::DSAError => e
        raise InvalidKey, e
      rescue OpenSSL::PKey::PKeyError
        false
      end
    end

  end
end
