# frozen_string_literal: true

require "protoc/tools/protoc/compiler"
require "protoc/tools/test_helper"

using Protoc::Tools::StandardExtensions

module Protoc
  module Tools
    # Test cases for Protoc
    class ProtocTest < Minitest::Test
      describe "Protoc" do
        it "has the correct version number" do
          protoc = Protoc::Compiler.new
          stdout, = Open3.capture2(protoc.protoc_bin.to_s, "--version")
          version = stdout[%r{\d+(?:\.\d+)+}]
          version.assert == Gem.root_spec.version.to_s[%r{^\d+(?:\.\d+)+}]
        end

        it "can be configured" do
          protoc = Protoc::Compiler.new do
            include_imports true
          end

          protoc.include_imports.assert == true
        end
      end
    end
  end
end
