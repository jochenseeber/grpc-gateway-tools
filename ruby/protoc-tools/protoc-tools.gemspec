# frozen_string_literal: true

require "json"
require "pathname"

Gem::Specification.new do |spec|
  raise "RubyGems 2.0 or newer is required." unless spec.respond_to?(:metadata)

  metadata = JSON.parse(File.read("#{__dir__}/../../project.json"))
  version = ->(component) { metadata.fetch(component).fetch("version").gsub("-", ".") }

  spec.name = "protoc-tools"
  spec.version = version.call("protobuf")
  spec.summary = "Protobuf Compiler (protoc) binaries"
  spec.required_ruby_version = ">= 2.6.0"

  spec.licenses = ["BSD-3-Clause"]
  spec.authors = ["Jochen Seeber"]
  spec.homepage = metadata.fetch("homepageUri")

  spec.metadata["bug_tracker_uri"] = metadata.fetch("ticketSystemUri")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = metadata.fetch("sourceCodeUri")

  spec.files = Dir[
    "*.md",
    "*.txt",
    "bundled/proto/**/*.proto",
    "cmd/**/*",
    "lib/**/*.rb",
  ]

  spec.bindir = "cmd"
  spec.executables = spec.files.filter { |f| File.dirname(f) == "cmd" && File.file?(f) }.map { |f| File.basename(f) }

  spec.require_paths = %w[lib bundled/proto]

  spec.add_dependency "docile", "~> 1.3"
  spec.add_dependency "os", "~> 1.1"

  spec.add_development_dependency "ae", "~> 1.8"
  spec.add_development_dependency "archive-zip", "~> 0.12"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 0.82"
end
