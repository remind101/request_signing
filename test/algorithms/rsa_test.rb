require 'test_helper'
require_relative './lint_test'

class TestRSAAlgorithm < Test
  include AlgorithmLintTest

  def make_algorithm
    RequestSigning.get_algorithm("rsa-sha256")
  end

  def secret_for_signing
    TEST_RSA_PRIVATE_KEY
  end

  def secret_for_verification
    TEST_RSA_PUBKEY
  end
end

