# frozen_string_literal: true

require "protoc/tools/protoc/output"

module Protoc
  module Tools
    module Protoc
      # Protoc compiler output
      class GrpcRubyOutput < Output
        protoc_output "grpc-ruby"

        def initialize
          super(target_dir: "generated/proto")
        end

        def default_plugin
          Pathname(Gem.bindir) / "grpc_tools_ruby_protoc_plugin"
        end
      end
    end
  end
end
