# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_signing/version'

Gem::Specification.new do |spec|
  spec.name          = "request_signing"
  spec.version       = RequestSigning::VERSION
  spec.authors       = ["Vlad Yarotsky"]
  spec.email         = ["vlad@remind101.com"]

  spec.summary       = %q{Implementation of http request signing draft https://tools.ietf.org/html/draft-cavage-http-signatures-08}
  spec.description   = %q{Implementation of http request signing draft https://tools.ietf.org/html/draft-cavage-http-signatures-08}
  spec.homepage      = "https://github.com/remind101/request_signing"
  spec.license       = "MIT"

  plugin_files = Dir["request_signing-*.gemspec"].map { |gemspec|
    eval(File.read(gemspec)).files
  }.flatten.uniq

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end - plugin_files

  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"
end
