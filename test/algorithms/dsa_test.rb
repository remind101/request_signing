require 'test_helper'
require_relative './lint_test'

class TestDSAAlgorithm < Test
  include AlgorithmLintTest

  def make_algorithm
    RequestSigning.get_algorithm("dsa-sha1")
  end

  def secret_for_signing
    TEST_DSA_PRIVATE_KEY
  end

  def secret_for_verification
    TEST_DSA_PUBKEY
  end
end
