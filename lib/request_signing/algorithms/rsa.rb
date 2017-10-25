require "openssl"

module RequestSigning
  module Algorithms

    class RSA
      # @param digester [OpenSSL::Digest]
      def initialize(digester)
        @digester = digester
      end

      # @param raw_private_key [String] RSA private key
      # @param str [String] string to sign
      # @raise [InvalidKey] when invalid RSA private key is supplied
      def create_signature(raw_private_key, str)
        key = OpenSSL::PKey::RSA.new(raw_private_key)
        key.sign(@digester, str)
      rescue OpenSSL::PKey::RSAError => e
        raise InvalidKey, e
      end

      # @param raw_public_key [String] RSA public key
      # @param signature [String] signature to verify
      # @param str [String] signed string
      # @raise [InvalidKey] when invalid RSA public key is supplied
      # @return true if signature is valid
      # @return false if signature is invalid
      def verify_signature(raw_public_key, signature, str)
        key = OpenSSL::PKey::RSA.new(raw_public_key)
        key.verify(@digester, signature, str)
      rescue OpenSSL::PKey::RSAError => e
        raise InvalidKey, e
      end
    end

  end
end

