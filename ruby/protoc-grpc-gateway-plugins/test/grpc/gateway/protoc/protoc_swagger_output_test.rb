# frozen_string_literal: true

require "grpc/gateway/test_helper"

require "protoc/tools/protoc/compiler"
require "grpc/gateway/protoc/swagger_output"

using Protoc::Tools::GemExtensions

module Grpc
  module Gateway
    module Protoc
      # Test cases for Protoc
      class ProtocSwaggerOutputTest < Minitest::Test
        describe "SwaggerOutput" do
          it "has the correct defaults" do
            output = SwaggerOutput.new
            output.class.output_name == "swagger"
          end

          it "has the correct version number" do
            output = SwaggerOutput.new

            stdout, = Open3.capture2(output.plugin.to_s, "--version")
            version = stdout[%r{\d+(?:\.\d+)+}]
            version.assert == Gem.root_spec.version.to_s[%r{^\d+(?:\.\d+)+}]
          end
        end
      end
    end
  end
end
