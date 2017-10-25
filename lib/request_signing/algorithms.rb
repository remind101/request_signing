module RequestSigning

  module Algorithms
    require "request_signing/algorithms/rsa"
    require "request_signing/algorithms/dsa"
    require "request_signing/algorithms/hmac"
  end

  @algorithms = {}

  def self.get_algorithm(name)
    @algorithms.fetch(name).call
  rescue KeyError
    raise UnsupportedAlgorithm, name
  end

  def self.register_algorithm(name, algorithm_factory)
    @algorithms[name] = algorithm_factory
  end

  register_algorithm "rsa-sha1",    ->() { Algorithms::RSA.new(OpenSSL::Digest::SHA1.new) }
  register_algorithm "rsa-sha256",  ->() { Algorithms::RSA.new(OpenSSL::Digest::SHA256.new) }
  register_algorithm "rsa-sha512",  ->() { Algorithms::RSA.new(OpenSSL::Digest::SHA512.new ) }
  register_algorithm "dsa-sha1",    ->() { Algorithms::DSA.new(OpenSSL::Digest::SHA1.new) }
  register_algorithm "hmac-sha1",   ->() { Algorithms::HMAC.new(OpenSSL::Digest::SHA1.new) }
  register_algorithm "hmac-sha256", ->() { Algorithms::HMAC.new(OpenSSL::Digest::SHA256.new) }
  register_algorithm "hmac-sha512", ->() { Algorithms::HMAC.new(OpenSSL::Digest::SHA512.new) }

end

