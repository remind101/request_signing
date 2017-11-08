require "aws-sdk-ssm"
require "request_signing"

module RequestSigning
  module KeyStores

    # AWS SSM-backed key store implementation
    # @see RequestSigning::Signer
    # @see RequestSigning::Verifier
    # @see http://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html
    class SSM

      ##
      # Makes a new instance of {RequestSigning::KeyStores::SSM}
      #
      # @param ssm_client [Aws::SSM::Client] an instance of configured SSM client
      # @param path [String] path prefix for SSM GetParametersByPath operation
      #
      # @return [RequestSigning::KeyStores::SSM]
      #
      # @see http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SSM/Client.html#get_parameters_by_path-instance_method
      ##
      def self.with_ssm_path(ssm_client:, path:)
        ssm_options = {
          path: path,
          recursive: false,
          with_decryption: true
        }
        new(ssm_client: ssm_client, ssm_options: ssm_options)
      end

      ##
      # Makes a new instance of {RequestSigning::KeyStores::SSM}
      #
      # @param ssm_client [Aws::SSM::Client] an instance of configured SSM client
      # @param ssm_options [Hash] custom parameters for SSM GetParametersByPath operation
      #
      # @return [RequestSigning::KeyStores::SSM]
      #
      # @see http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SSM/Client.html#get_parameters_by_path-instance_method
      ##
      def self.with_ssm_options(ssm_client:, ssm_options:)
        new(ssm_client: ssm_client, ssm_options: ssm_options)
      end

      def initialize(ssm_client:, ssm_options:)
        @ssm_client = ssm_client
        @ssm_options = ssm_options
        @loaded = false
        @keys = {}
      end

      # @param key_id [String] id of the key to retrieve
      #
      # @return [String] key contents
      #
      # @raise [RequestSigning::KeyNotFound] when requested key is not found
      # @raise [Aws::SSM::Errors::ServiceError] when keys were not eager loaded and loading fails
      def fetch(key_id)
        load! unless loaded?
        @keys.fetch(key_id)
      rescue KeyError
        raise KeyNotFound, key_id: key_id
      end

      # @param key_id [String] id of the key
      #
      # @return true if store knows this key
      # @return false if store does not recognize the key
      #
      # @raise [Aws::SSM::Errors::ServiceError] when keys were not eager loaded and loading fails
      def key?(key_id)
        load! unless loaded?
        @keys.key?(key_id)
      end

      # Eager loads the keys
      #
      # @raise [Aws::SSM::Errors::ServiceError]
      def load!
        return if loaded?

        keys = {}
        next_token = nil
        loop do
          params = @ssm_options.merge(next_token: next_token)
          response = @ssm_client.get_parameters_by_path(params)
          response.parameters.each do |p|
            keys[p.name] = p.value
          end
          next_token = String(response.next_token)
          break if next_token.empty?
        end

        @keys = keys
        @loaded = true
      end

      def loaded?
        !!@loaded
      end
    end

  end
end

