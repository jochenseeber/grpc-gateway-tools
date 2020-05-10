# frozen_string_literal: true

require "json"
require "pathname"

metadata = JSON.parse(File.read("#{__dir__}/../../../project.json"))

Gem::Specification.new do |spec|
  raise "RubyGems 2.0 or newer is required." unless spec.respond_to?(:metadata)

  spec.name = "foo_service"
  spec.version = metadata.fetch("version").gsub(%r{-([a-z]+)}i, ".\\1")
  spec.summary = "GRPC Gateway Tools example project"
  spec.required_ruby_version = ">= 2.6.0"

  spec.licenses = ["BSD-3-Clause"]
  spec.authors = ["Jochen Seeber"]
  spec.homepage = metadata.fetch("homepageUri")

  spec.metadata["bug_tracker_uri"] = metadata.fetch("ticketSystemUri")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = metadata.fetch("sourceCodeUri")

  spec.files = Dir[
    "*.md",
    "proto/**/*.proto",
    "generated/proto/**/*.rb",
  ]

  spec.require_paths = %w[generated/proto proto]

  spec.add_development_dependency "grpc-tools", ">= #{metadata.fetch("grpc").fetch("version")}"
  spec.add_development_dependency "protoc-grpc-gateway-plugins", "= #{spec.version}"
  spec.add_development_dependency "rake", "~> 13.0"
end
