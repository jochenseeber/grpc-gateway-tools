# frozen_string_literal: true

require "docile"
require "pathname"
require "protoc/tools/standard_extensions"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    module Protoc
      # Protoc compiler
      class Compiler
        # Output configuration
        class Output
          dsl_accessor :plugin, convert: :to_pathname
          dsl_accessor :target_dir, convert: :to_pathname

          def initialize(plugin: nil, target_dir: nil)
            @plugin = plugin&.to_pathname
            @target_dir = target_dir&.to_pathname
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

        dsl_accessor :dependency_dir, convert: :to_pathname
        dsl_accessor :descriptor_set_out, convert: :to_pathname
        dsl_accessor :error_format
        dsl_accessor :include_imports
        dsl_accessor :include_source_info
        dsl_list_accessor :descriptor_sets_in, :descriptor_set_in, convert: :to_pathname
        dsl_list_accessor :outputs, :output
        dsl_list_accessor :plugins, :plugin, convert: :to_pathname
        dsl_list_accessor :proto_dirs, :proto_dir, convert: :to_pathname

        def initialize(&block)
          @plugins = []
          @outputs = []
          @descriptor_sets_in = []
          @proto_dirs = []

          Docile.dsl_eval(self, &block) if block_given?
        end

        def execute(command:)
          puts command.join(" ")
          system(*command, exception: true)
        end

        def run(proto_files:)
          outputs.each do |output|
            output.target_dir.mkpath
          end

          if dependency_dir
            Array(proto_files).each do |proto_file|
              (dependency_dir / proto_file).dirname.mkpath

              command = arguments(proto_files: proto_file)
              execute(command: command)
            end
          else
            command = arguments(proto_files: proto_files)
            execute(command: command)
          end
        end

        def protoc_bin
          @protoc_bin ||= begin
            spec = Gem.loaded_specs.fetch("protoc-tools")
            Pathname(spec.full_gem_path) / spec.bindir / "protoc"
          end
        end

        def proto_path
          @proto_path ||= Gem.loaded_specs.values.reject do |gem|
            Bundler::GemHelper.gemspec.name == gem.name
          end.flat_map(&:full_require_paths).reject do |d|
            Pathname(d).glob("**/*.proto").empty?
          end
        end

        protected

        def dependency_out(proto_file:)
          dependency_dir&.then { |d| d / "#{proto_file}.d" }
        end

        def lookup_output_class_name(method:)
          output_class_name = :"#{method.split("_").map(&:capitalize).join}put"

          if Protoc::Tools::Protoc::Output.const_defined?(output_class_name)
            Protoc::Tools::Protoc::Output.const_get(output_class_name)
          end
        end

        def arguments(proto_files:)
          all_plugins = plugins + outputs.map(&:plugin).compact.uniq

          [
            protoc_bin.to_s,
            all_plugins.map { |p| "--plugin=#{p}" },
            "--proto_path=#{(proto_dirs + proto_path).map(&:to_s).join(":")}",
            descriptor_sets_in.if_present { |d| "--descriptor_set_in=#{d.map(&:to_s).join(",")}" },
            descriptor_set_out.if_present { |d| "--descriptor_set_out=#{d}" },
            include_imports.if_present("--include_imports"),
            include_source_info.if_present("--include_source_info"),
            dependency_dir.if_present { |d| "--dependency_out=#{(d / "#{Array(proto_files).first}.d")}" },
            error_format.if_present { |_f| "--error_format=#{error_format}" },
            outputs.map(&:to_arguments).flatten,
            Array(proto_files).map(&:to_s)
          ].flatten.compact
        end
      end
    end
  end
end
