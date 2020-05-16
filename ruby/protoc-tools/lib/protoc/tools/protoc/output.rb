# frozen_string_literal: true

require "protoc/tools/core_extensions"

using Protoc::Tools::CoreExtensions

module Protoc
  module Tools
    module Protoc
      # Output configuration
      class Output
        dsl_accessor :plugin, convert: :to_pathname
        dsl_accessor :target_dir, convert: :to_pathname

        def initialize(plugin: nil, target_dir: nil)
          @plugin = plugin&.to_pathname
          @target_dir = target_dir&.to_pathname
        end

        def to_arguments
          ["--#{self.class.output_name}_out=#{@target_dir}"]
        end

        class << self
          NAME_REGEXP = %r{^[a-z][-_a-z0-9]+$}.freeze

          def protoc_output(output_name)
            raise "Name must be a string" unless output_name.is_a?(String)
            raise "Name must match '#{NAME_REGEXP}'" unless NAME_REGEXP =~ output_name

            define_singleton_method(:output_name) do
              output_name
            end
          end

          def output_name
            raise NotImplementedError, "Subclasses must implement this method"
          end

          def output_method_name
            :"#{output_name.gsub("-", "_")}_out"
          end
        end
      end
    end
  end
end
