# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_signing/version'

Gem::Specification.new do |spec|
  spec.name          = "request_signing"
  spec.version       = RequestSigning::VERSION
  spec.authors       = ["Vlad Yarotsky"]
  spec.email         = ["vlad@remind101.com"]

  spec.summary       = %q{Implementation of http requets signing draft https://tools.ietf.org/html/draft-cavage-http-signatures-08}
  spec.description   = %q{Implementation of http requets signing draft https://tools.ietf.org/html/draft-cavage-http-signatures-08}
  spec.homepage      = "https://github.com/remind101/request_signing"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "yard"
end
