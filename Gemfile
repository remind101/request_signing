source 'https://rubygems.org'

gemspec name: "request_signing"

Dir["request_signing-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/request_signing-(.*)\.gemspec/).flatten.first
  gemspec(name: "request_signing-#{plugin}", development_group: plugin)
end

group :test do
  gem "rake", "~> 10.0"
  gem "minitest", "~> 5.0"
  gem "rack", "~> 2.0"
  gem "yard", "~> 0.9"
end
