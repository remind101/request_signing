require 'test_helper'
require_relative './lint_test'

class TestHMACAlgorithm < Test
  include AlgorithmLintTest

  def make_algorithm
    RequestSigning.get_algorithm("hmac-sha256")
  end

  def secret_for_signing
    TEST_HMAC_SECRET
  end

  def secret_for_verification
    TEST_HMAC_SECRET
  end
end
