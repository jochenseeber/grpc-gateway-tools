# frozen_string_literal: true

require "protoc/tools/protoc/compiler"
require "protoc/tools/standard_extensions"

using Protoc::Tools::StandardExtensions

module Grpc
  module Gateway
    # Protoc output classes
    module Protoc
      # Swagger output
      ::Protoc::Tools::Protoc::Compiler.output_class(type: "grpc-gateway") do
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
