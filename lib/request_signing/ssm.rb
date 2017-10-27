require "aws-sdk-ssm"
require "request_signing"

module RequestSigning
  module KeyStores

    class SSM
      def self.with_ssm_path(ssm_client:, path:)
        ssm_options = {
          path: path,
          recursive: false,
          with_decryption: true
        }
        new(ssm_client: ssm_client, ssm_options: ssm_options)
      end

      def self.with_ssm_options(ssm_client:, ssm_options:)
        new(ssm_client: ssm_client, ssm_options: ssm_options)
      end

      def initialize(ssm_client:, ssm_options:)
        @ssm_client = ssm_client
        @ssm_options = ssm_options
        @loaded = false
        @keys = {}
      end

      def fetch(key_id)
        load! unless loaded?
        @keys.fetch(key_id)
      rescue KeyError
        raise KeyNotFound, key_id
      end

      def key?(key_id)
        load! unless loaded?
        @keys.key?(key_id)
      end

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

