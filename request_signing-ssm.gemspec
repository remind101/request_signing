# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_signing/version'

Gem::Specification.new do |spec|
  spec.name          = "request_signing-ssm"
  spec.version       = "0.1.0.pre1"
  spec.authors       = ["Vlad Yarotsky"]
  spec.email         = ["vlad@remind101.com"]

  spec.summary       = %q{AWS SSM key store for request_signing gem}
  spec.description   = %q{AWS SSM key store for request_signing gem}
  spec.homepage      = "https://github.com/remind101/request_signing"
  spec.license       = "MIT"

  spec.files         = ["lib/request_signing/ssm.rb"]

  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"

  spec.add_dependency "request_signing", RequestSigning::VERSION
  spec.add_dependency "aws-sdk-ssm", "~> 1"
end
