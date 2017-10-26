require "rake/testtask"
require "yard"

require "bundler/gem_helper"

namespace :request_signing do
  Bundler::GemHelper.install_tasks :name => "request_signing"
end

namespace :"request_signing-rack" do
  Bundler::GemHelper.install_tasks :name => "request_signing-rack"
end

namespace :"request_signing-faraday" do
  Bundler::GemHelper.install_tasks :name => "request_signing-faraday"
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
