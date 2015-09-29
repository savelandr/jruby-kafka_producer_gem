require 'rubygems'
require 'rake'
require 'rubygems/package_task'

update_spec = Gem::Specification.new do |spec|
  spec.author = "Bob Saveland"
  spec.email = "savelandr@aol.com"
  spec.homepage = "http://adsqa.office.aol.com"
  spec.platform = "java"
  spec.description = "Kafka producer for testing convenience"
  spec.summary = "Kafka producer"
  spec.name = "jruby-kafka_producer"
  spec.version = "2.0.0"
  spec.require_path = "lib"
  spec.files = ['README.md', 'CHANGELOG', 'lib/jruby/kafka_producer.rb']
  spec.add_dependency "jruby-kafka", "~> 0.8.2"
end

Gem::PackageTask.new(update_spec) do |spec|
end
