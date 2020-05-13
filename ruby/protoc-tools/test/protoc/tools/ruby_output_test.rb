# frozen_string_literal: true

require "protoc/tools/protoc/output/ruby_output"
require "protoc/tools/test_helper"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    # Test cases for Protoc
    class RubyOutputTest < Minitest::Test
      describe "RubyOutput" do
        it "is registered" do
          output_class = Protoc::Compiler.output_classes.fetch("ruby")
          output_class.type.assert == "ruby"
        end

        it "can be created" do
          output_class = Protoc::Compiler.output_classes.fetch("ruby")
          output = output_class.new
          output.target_dir.assert == Pathname("generated/proto")
          output.to_arguments.assert.any? { |a| a.start_with?("--ruby_out=") }
        end

        it "can be configured" do
          protoc = Protoc::Compiler.new do
            ruby_out do
              target_dir "generated/proto_ruby"
            end
          end

          output = protoc.outputs.find { |o| o.class.type == "ruby" }
          output.assert.not.nil?
          output.target_dir.assert == Pathname("generated/proto_ruby")
        end
      end
    end
  end
end
