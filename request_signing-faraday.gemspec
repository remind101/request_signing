# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_signing/version'

Gem::Specification.new do |spec|
  spec.name          = "request_signing-faraday"
  spec.version       = "0.1.0.pre2"
  spec.authors       = ["Vlad Yarotsky"]
  spec.email         = ["vlad@remind101.com"]

  spec.summary       = %q{Faraday middleware for request signing}
  spec.description   = %q{Faraday middleware for request signing}
  spec.homepage      = "https://github.com/remind101/request_signing"
  spec.license       = "MIT"

  spec.files         = ["lib/request_signing/faraday.rb"]

  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"

  spec.add_dependency "request_signing", RequestSigning::VERSION
  spec.add_dependency "faraday", "~> 0.9"
end
