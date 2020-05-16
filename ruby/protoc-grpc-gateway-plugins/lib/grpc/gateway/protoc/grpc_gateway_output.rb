# frozen_string_literal: true

require "protoc/tools/protoc/output"
require "protoc/tools/gem_extensions"

using Protoc::Tools::GemExtensions

module Grpc
  module Gateway
    module Protoc
      # GRPC Gateway output
      class GrpcGatewayOutput < ::Protoc::Tools::Protoc::Output
        protoc_output "grpc-gateway"

        def initialize
          super(target_dir: "generated/grpc_gateway")
        end

        def default_plugin
          Gem.platform_bin_file(spec_name: "protoc-grpc-gateway-plugins", bin_name: "bundled/protoc-gen-grpc-gateway")
        end
      end
    end
  end
end
