# frozen_string_literal: true

require "protoc/grpc/gateway/test_helper"

require "grpc/gateway/protoc/swagger_output"

using Protoc::Tools::StandardExtensions

module Protoc
  module Grpc
    module Gateway
      # Test cases for Protoc
      class ProtocSwaggerPluginTest < Minitest::Test
        describe "Swagger Plugin" do
          it "is registered" do
            output_class = Protoc::Tools::Protoc::Compiler.output_classes.fetch("swagger")
            output_class.type.assert == "swagger"
          end

          it "has the correct version number" do
            output = Protoc::Tools::Protoc::Compiler.output_classes.fetch("swagger").new
            stdout, = Open3.capture2(output.plugin.to_s, "--version")
            version = stdout[%r{\d+(?:\.\d+)+}]
            version.assert == Gem.root_spec.version.to_s[%r{^\d+(?:\.\d+)+}]
          end
        end
      end
    end
  end
end
