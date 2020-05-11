# frozen_string_literal: true

require "docile"
require "fileutils"
require "protoc/tools/standard_extensions"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    module Protoc
      # Protoc compiler
      class Compiler
        # Output configuration
        class Output
          dsl_accessor :plugin
          dsl_accessor :target_dir

          def initialize(plugin: nil, target_dir: nil)
            @plugin = plugin
            @target_dir = target_dir
          end

          def to_arguments
            ["--#{self.class.type}_out=#{@target_dir}"]
          end
        end

        class << self
          def output_class(type:, &block)
            raise "Type must be a string" unless type.is_a?(String)
            unless %r{^[a-z][-_a-z0-9]+$} =~ type
              raise "Type must contain only letters 'a'-'z', digits '0'-'9', '-' and '_', and must start with a letter"
            end

            output_class = Class.new(Output, &block)
            output_class.define_singleton_method(:type) do
              type
            end

            @output_classes ||= {}
            @output_classes[type] = output_class

            method_name = :"#{type.gsub("-", "_")}_out".to_sym

            Compiler.define_method(method_name) do |**method_parameters, &method_block|
              output_handler = output_class.new(**method_parameters, &method_block)
              Docile.dsl_eval(output_handler, &method_block) if method_block
              output output_handler
            end
          end

          def output_classes
            @output_classes.dup.freeze
          end
        end

        dsl_accessor :dependency_out
        dsl_accessor :descriptor_set_out
        dsl_accessor :error_format
        dsl_accessor :include_imports
        dsl_accessor :include_source_info
        dsl_list_accessor :descriptor_sets_in, :descriptor_set_in
        dsl_list_accessor :outputs, :output
        dsl_list_accessor :plugins, :plugin

        def initialize(&block)
          @plugins = []
          @outputs = []
          @descriptor_sets_in = []

          Docile.dsl_eval(self, &block) if block_given?
        end

        def run(base_dirs:, files:)
          command = arguments(base_dirs: base_dirs, files: files)

          outputs.each do |output|
            FileUtils.mkpath(output.target_dir)
          end

          puts command.join(" ")
          system(*command, exception: true)
        end

        def protoc_bin
          @protoc_bin ||= begin
            spec = Gem.loaded_specs.fetch("protoc-tools")
            File.join(spec.full_gem_path, spec.bindir, "protoc")
          end
        end

        def proto_path
          @proto_path ||= Gem.loaded_specs.values.reject do |gem|
            Bundler::GemHelper.gemspec.name == gem.name
          end.flat_map(&:full_require_paths).reject do |d|
            Dir.glob("**/*.proto", base: d).empty?
          end
        end

        protected

        def lookup_output_class_name(method:)
          output_class_name = :"#{method.split("_").map(&:capitalize).join}put"

          if Protoc::Tools::Protoc::Output.const_defined?(output_class_name)
            Protoc::Tools::Protoc::Output.const_get(output_class_name)
          end
        end

        def arguments(base_dirs:, files:)
          all_plugins = plugins + outputs.map(&:plugin).compact.uniq

          [
            protoc_bin,
            all_plugins.map { |p| "--plugin=#{p}" },
            "--proto_path=#{(Array(base_dirs) + proto_path).join(":")}",
            descriptor_sets_in.empty? ? nil : "--descriptor_set_in=#{descriptor_sets_in.join(",")}",
            descriptor_set_out ? "--descriptor_set_out=#{descriptor_set_out}" : nil,
            include_imports ? "--include_imports" : nil,
            include_source_info ? "--include_source_info" : nil,
            dependency_out ? "--dependency_out=#{dependency_out}" : nil,
            error_format ? "--error_format=#{error_format}" : nil,
            outputs.map(&:to_arguments).flatten,
            Array(files)
          ].flatten.compact
        end
      end
    end
  end
end
