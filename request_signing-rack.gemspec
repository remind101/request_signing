# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "request_signing-rack"
  spec.version       = "0.1.0.pre3"
  spec.authors       = ["Vlad Yarotsky"]
  spec.email         = ["vlad@remind101.com"]

  spec.summary       = %q{Rack middleware for request signature verification}
  spec.description   = %q{Rack middleware for request signature verification based on request_signing}
  spec.homepage      = "https://github.com/remind101/request_signing"
  spec.license       = "MIT"

  spec.files         = ["lib/request_signing/rack.rb"]

  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"

  spec.add_dependency "request_signing", "~> 0.1.0.pre2"
  spec.add_dependency "rack", "~> 2.0"
end
