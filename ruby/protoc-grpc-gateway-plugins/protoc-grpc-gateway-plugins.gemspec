# frozen_string_literal: true

require "json"
require "pathname"

Gem::Specification.new do |spec|
  raise "RubyGems 2.0 or newer is required." unless spec.respond_to?(:metadata)

  metadata = JSON.parse(File.read("#{__dir__}/../../project.json"))
  version = ->(component) { metadata.fetch(component).fetch("version").gsub("-", ".") }

  spec.name = "protoc-grpc-gateway-plugins"
  spec.version = version.call("grpc-gateway")
  spec.summary = "Generate GRPC Gateway code from Proto Files (https://github.com/grpc-ecosystem/grpc-gateway)"
  spec.required_ruby_version = ">= 2.6.0"

  spec.licenses = ["BSD-3-Clause"]
  spec.authors = ["Jochen Seeber"]
  spec.homepage = metadata.fetch("homepageUri")

  spec.metadata["bug_tracker_uri"] = metadata.fetch("ticketSystemUri")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = metadata.fetch("sourceCodeUri")

  spec.files = Dir[
    "*.md",
    "bundled/**/*",
    "cmd/*",
    "lib/**/*.rb",
  ]

  spec.bindir = "cmd"
  spec.executables = spec.files.grep(%r{^cmd/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "os", "~> 1.1"
  spec.add_dependency "protoc-grpc-gateway-options", "= #{spec.version}"

  spec.add_development_dependency "ae", "~> 1.8"
  spec.add_development_dependency "grpc-tools", "= #{version.call("grpc")}"
  spec.add_development_dependency "minitar", "~> 0.8"
  spec.add_development_dependency "minitar-cli", "~> 0.8"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "protoc-tools", "= #{version.call("protobuf")}"
  spec.add_development_dependency "rubocop", "~> 0.82"
  spec.add_development_dependency "zlib", "~> 1.1"
end
