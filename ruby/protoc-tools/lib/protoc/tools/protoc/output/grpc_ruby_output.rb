# frozen_string_literal: true

require "protoc/tools/protoc/compiler"

module Protoc
  module Tools
    module Protoc
      # Output classes
      module Output
        # Protoc compiler output
        Compiler.output_class(type: "grpc-ruby") do
          def initialize
            super(target_dir: "generated/proto")
          end

          def default_plugin
            Gem.loaded_specs.fetch("grpc-tools").bin_file("grpc_tools_ruby_protoc_plugin")
          end
        end
      end
    end
  end
end
