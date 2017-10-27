require "rake/testtask"
require "yard"

require "bundler/gem_helper"

gems = [
  :request_signing,
  :"request_signing-rack",
  :"request_signing-faraday",
  :"request_signing-ssm",
]

gems.each do |g|
  namespace g do
    Bundler::GemHelper.install_tasks :name => g.to_s
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = ['lib/**/*.rb']
end

task :default => :test

desc "Build and install request_signing and it's plugin gems into system gems"
task :install => gems.map { |g| "#{g}:install" }

desc "Build and install request_signing and it's plugin gems into system gems without network access"
task :"install:local" => gems.map { |g| "#{g}:install:local" }
