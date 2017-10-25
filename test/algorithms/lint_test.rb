require 'test_helper'

module AlgorithmLintTest
  def make_algorithm
    raise NotImplementedError
  end

  def secret_for_signing
    raise NotImplementedError
  end

  def secret_for_verification
    raise NotImplementedError
  end

  def setup
    @alg = make_algorithm
  end

  def self.included(base)
    base.class_eval do
      test "#{name}#create_signature makes a signature" do
        signature = @alg.create_signature(secret_for_signing, "test")
        refute_empty signature, "expected signature to be created"
      end

      test "#{name}#create_signature raises InvalidKey" do
        assert_raises(RequestSigning::InvalidKey) do
          @alg.create_signature("", "test")
        end
      end

      test "#{name}#verify signature can verify a signature created by itself" do
        signature = @alg.create_signature(secret_for_signing, "test")
        assert @alg.verify_signature(secret_for_verification, signature, "test"), "expected signature verification to pass"
      end

      test "#{name}#verify signature fails verification of corrupted signature" do
        refute @alg.verify_signature(secret_for_verification, "lol", "test"), "expected signature verification to fail"
      end

      test "#{name}#verify_signature raises InvalidKey" do
        assert_raises(RequestSigning::InvalidKey) do
          @alg.verify_signature("", "lol", "test")
        end
      end
    end
  end
end
