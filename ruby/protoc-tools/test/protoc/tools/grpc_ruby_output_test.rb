# frozen_string_literal: true

require "protoc/tools/protoc/grpc_ruby_output"
require "protoc/tools/test_helper"

using Protoc::Tools::CoreExtensions

module Protoc
  module Tools
    # Test cases for Protoc
    class GrpcRubyOutputTest < Minitest::Test
      describe "GrpcRubyOutput" do
        it "has correct defaults" do
          compiler = Protoc::Compiler.new do
            grpc_ruby_out
          end

          output = compiler.outputs.find { |o| o.class.output_name == "grpc-ruby" }
          output.assert.not.nil?
          output.target_dir.assert == Pathname("generated/proto")
        end

        it "can be configured" do
          compiler = Protoc::Compiler.new do
            grpc_ruby_out do
              target_dir "generated/proto_ruby"
            end
          end

          output = compiler.outputs.find { |o| o.class.output_name == "grpc-ruby" }
          output.assert.not.nil?
          output.to_arguments.assert == ["--grpc-ruby_out=generated/proto_ruby"]
        end
      end
    end
  end
end
