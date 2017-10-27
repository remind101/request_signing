require "request_signing/errors"

module RequestSigning
  module KeyStores

    # Simple static key store implementation.
    # @see RequestSigning::Signer
    # @see RequestSigning::Verifier
    class Static

      ##
      # Makes a new instance of {RequestSigning::KeyStores::Static} from `keys_str`
      #
      # @param keys_str [String] a list of keys in the form of
      #   `keyId:keySecret,keyId2:keySecret2`
      # @raise [RequestSigning::MalformedKeysString] when the `keys_str` is malformed
      #
      # @note not recommended for use with anything other than HMAC secrets.
      ##
      def self.from_string(keys_str)
        keys = keys_str.split(",").each_with_object({}) do |id_key, r|
          id, key = id_key.split(":", 2).map(&:strip)
          raise MalformedKeysString unless id && key
          r[id] = key
        end
        new(keys)
      end

      # @param keys [Hash{String=>String}] a map from keyId to key value
      # @example
      #   RequestSigning::KeyStores::Static.new("my_key" => "key secret")
      def initialize(keys)
        @keys = keys
      end

      # @param key_id [String] id of the key to retrieve
      # @return [String] key contents
      # @raise [RequestSigning::KeyNotFound] when requested key is not found
      def fetch(key_id)
        @keys.fetch(key_id)
      rescue KeyError
        raise KeyNotFound, key_id
      end

      # @param key_id [String] id of the key
      # @return true if store knows this key
      # @return false if store does not recognize the key
      def key?(key_id)
        @keys.key?(key_id)
      end
    end

  end
end
