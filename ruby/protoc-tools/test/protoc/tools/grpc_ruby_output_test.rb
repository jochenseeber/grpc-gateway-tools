# frozen_string_literal: true

require "protoc/tools/protoc/output/grpc_ruby_output"
require "protoc/tools/test_helper"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    # Test cases for Protoc
    class RubyOutputTest < Minitest::Test
      describe "GrpcRubyOutput" do
        it "is registered" do
          output_class = Protoc::Compiler.output_classes.fetch("grpc-ruby")
          output_class.type.assert == "grpc-ruby"
        end

        it "can be created" do
          output_class = Protoc::Compiler.output_classes.fetch("grpc-ruby")
          output = output_class.new
          output.target_dir.assert == "generated/proto"
          output.to_arguments.assert.any? { |a| a.start_with?("--grpc-ruby_out=") }
        end

        it "can be configured" do
          compiler = Protoc::Compiler.new do
            grpc_ruby_out do
              plugin "protoc-grpc-ruby-plugin"
              target_dir "generated/proto_ruby"
            end
          end

          output = compiler.outputs.find { |o| o.class.type == "grpc-ruby" }
          output.assert.not.nil?
          output.target_dir.assert == "generated/proto_ruby"
        end
      end
    end
  end
end
