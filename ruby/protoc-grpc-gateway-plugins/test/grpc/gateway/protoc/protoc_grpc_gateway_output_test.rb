# frozen_string_literal: true

require "grpc/gateway/test_helper"

require "grpc/gateway/protoc/grpc_gateway_output"
require "protoc/tools/protoc/compiler"

using Protoc::Tools::GemExtensions

module Grpc
  module Gateway
    module Protoc
      # Test cases for Protoc
      class GrpcGatewayOutputTest < Minitest::Test
        describe "GrpcGatewayOutput" do
          it "has the correct defaults" do
            output = GrpcGatewayOutput.new
            output.class.output_name.assert == "grpc-gateway"
          end

          it "has the correct version number" do
            output = GrpcGatewayOutput.new

            stdout, = Open3.capture2(output.plugin.to_s, "--version")
            version = stdout[%r{\d+(?:\.\d+)+}]
            version.assert == Gem.root_spec.version.to_s[%r{^\d+(?:\.\d+)+}]
          end
        end
      end
    end
  end
end
