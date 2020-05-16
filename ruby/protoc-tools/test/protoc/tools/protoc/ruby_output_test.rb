# frozen_string_literal: true

require "protoc/tools/protoc/ruby_output"
require "protoc/tools/test_helper"

using Protoc::Tools::CoreExtensions

module Protoc
  module Tools
    module Protoc
      # Test cases for Protoc
      class RubyOutputTest < Minitest::Test
        describe "RubyOutput" do
          it "has correct defaults" do
            compiler = Protoc::Compiler.new do
              ruby_out
            end

            output = compiler.outputs.find { |o| o.class.output_name == "ruby" }
            output.assert.not.nil?
            output.target_dir.assert == Pathname("generated/proto")
          end

          it "can be configured" do
            compiler = Protoc::Compiler.new do
              ruby_out do
                target_dir "generated/proto_ruby"
              end
            end

            output = compiler.outputs.find { |o| o.class.output_name == "ruby" }
            output.assert.not.nil?
            output.target_dir.assert == Pathname("generated/proto_ruby")
            output.to_arguments.assert == ["--ruby_out=generated/proto_ruby"]
          end
        end
      end
    end
  end
end
