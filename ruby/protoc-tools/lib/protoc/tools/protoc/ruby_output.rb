# frozen_string_literal: true

require "protoc/tools/protoc/output"

module Protoc
  module Tools
    module Protoc
      # Protoc compiler output
      class RubyOutput < Output
        protoc_output "ruby"

        def initialize
          super(target_dir: "generated/proto")
        end
      end
    end
  end
end
