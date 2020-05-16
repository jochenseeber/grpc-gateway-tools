# frozen_string_literal: true

require "docile"
require "pathname"
require "protoc/tools/core_extensions"
require "protoc/tools/gem_extensions"

using Protoc::Tools::CoreExtensions
using Protoc::Tools::GemExtensions

module Protoc
  module Tools
    module Protoc
      # Protoc compiler
      class Compiler
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
          @output_classes = {}
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
          Gem.platform_bin_file(spec_name: "protoc-tools", bin_name: "bundled/protoc")
        end

        def proto_path
          @proto_path ||= Gem.loaded_specs.values.reject do |gem|
            Bundler::GemHelper.gemspec.name == gem.name
          end.flat_map(&:full_require_paths).reject do |d|
            Pathname(d).glob("**/*.proto").empty?
          end
        end

        def method_missing(method, *arguments, &block)
          output_class = lookup_output_class(name: method)

          if output_class
            define_output_method(name: method, output_class: output_class)
            send(method, *arguments, &block)
          else
            super
          end
        end

        def respond_to_missing?(symbol, include_all)
          lookup_output_class(name: symbol) ? true : super
        end

        protected

        def lookup_output_class(name:)
          @output_classes.fetch(name) do
            output_class = Output.descendants.find { |c| c.output_method_name == name }
            @output_classes[name] = output_class if output_class
          end
        end

        def define_output_method(name:, output_class:)
          define_singleton_method(name) do |*method_parameters, **method_options, &method_block|
            output_handler = if method_options.empty?
              output_class.new(*method_parameters, &method_block)
            else
              output_class.new(*method_parameters, **method_options, &method_block)
            end

            Docile.dsl_eval(output_handler, &method_block) if method_block
            @outputs << output_handler
          end
        end

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
            "--proto_path=#{(proto_dirs + proto_path).map(&:to_s).join(File::PATH_SEPARATOR)}",
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
