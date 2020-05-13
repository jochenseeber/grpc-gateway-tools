# frozen_string_literal: true

require "protoc/grpc/gateway/test_helper"

require "grpc/gateway/protoc/grpc_gateway_output"

using Protoc::Tools::StandardExtensions

module Protoc
  module Grpc
    module Gateway
      # Test cases for Protoc
      class ProtocTest < Minitest::Test
        describe "Protoc" do
          it "is registered" do
            output_class = Protoc::Tools::Protoc::Compiler.output_classes.fetch("grpc-gateway")
            output_class.type.assert == "grpc-gateway"
          end

          it "has the correct version number" do
            output = Protoc::Tools::Protoc::Compiler.output_classes.fetch("grpc-gateway").new
            stdout, = Open3.capture2(output.plugin.to_s, "--version")
            version = stdout[%r{\d+(?:\.\d+)+}]
            version.assert == Gem.root_spec.version.to_s[%r{^\d+(?:\.\d+)+}]
          end
        end
      end
    end
  end
end
