# frozen_string_literal: true

require "protoc/tools/protoc/output"
require "protoc/tools/gem_extensions"

using Protoc::Tools::GemExtensions

module Grpc
  module Gateway
    module Protoc
      # Swagger output
      class SwaggerOutput < ::Protoc::Tools::Protoc::Output
        protoc_output "swagger"

        def initialize
          super(target_dir: "generated/swagger")
        end

        def default_plugin
          Gem.platform_bin_file(spec_name: "protoc-grpc-gateway-plugins", bin_name: "bundled/protoc-gen-swagger")
        end
      end
    end
  end
end
