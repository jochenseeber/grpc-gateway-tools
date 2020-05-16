# frozen_string_literal: true

require "os"
require "pathname"

module Protoc
  module Tools
    # Gem extensions
    module GemExtensions
      refine Gem.singleton_class do
        def root_spec
          root_spec = loaded_specs.values.find do |spec|
            spec.source.is_a?(Bundler::Source::Gemspec) && spec.source.path.to_s == "."
          end

          root_spec || raise("Could not find root specification")
        end

        def platform_bin_file(spec_name:, bin_name:)
          full_name = platform_bin_name(name: bin_name)
          spec = Gem.loaded_specs.fetch(spec_name)
          Pathname(spec.bin_file(full_name))
        end

        def platform_bin_name(name:)
          host = if OS.osx?
            "darwin"
          elsif OS.linux?
            "linux"
          elsif OS.windows?
            "windows"
          else
            abort("Unknown platform '#{OS.host_os}'")
          end

          cpu = case OS.host_cpu
            when "x86_64"
              "x86_64"
            else
              abort("Unknown cpu architecture '#{OS.host_cpu}'")
          end

          ext = RbConfig::CONFIG["EXEEXT"]
          "#{name}-#{host}-#{cpu}#{ext}"
        end
      end
    end
  end
end
