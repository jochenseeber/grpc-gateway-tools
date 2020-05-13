# frozen_string_literal: true

require "docile"
require "fileutils"
require "protoc/tools/protoc/output/grpc_ruby_output"
require "protoc/tools/protoc/output/ruby_output"
require "protoc/tools/standard_extensions"
require "rake/tasklib"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    # Protoc Rake task
    class ProtocTask < Rake::TaskLib
      attr_reader :name

      dsl_accessor :proto_dir
      dsl_list_accessor :proto_files, :proto_file

      def initialize(name:, &block)
        scope = Rake.application.current_scope
        @name = name
        @protoc = Protoc::Compiler.new
        @protoc.proto_dirs = Pathname("proto")
        @protoc.dependency_dir = Pathname("build").join("dependencies", *scope, *name.split(":"))

        Docile.dsl_eval(self, &block) if block

        define
      end

      def protoc(&block)
        Docile.dsl_eval(@protoc, &block)
      end

      def define
        task @name do
          @protoc.run(proto_files: @proto_files)
        end
      end
    end
  end
end
