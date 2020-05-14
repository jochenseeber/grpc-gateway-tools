# frozen_string_literal: true

require "os"
require "pathname"

module Protoc
  module Tools
    # Gem extensions
    module StandardExtensions
      EMPTY = Object.new.freeze

      refine Object.singleton_class do
        def dsl_accessor(name, convert: nil)
          variable_name = :"@#{name}"
          default_method_name = :"default_#{name}"
          setter_name = :"#{name}="
          convert_proc = convert&.to_proc

          define_method(name) do |value = EMPTY|
            if value.equal?(EMPTY)
              result = instance_variable_get(variable_name)

              if result.nil? && respond_to?(default_method_name)
                send(default_method_name)
              else
                result
              end
            else
              send(setter_name, value)
            end
          end

          define_method(setter_name) do |value|
            value = convert_proc.call(value) if convert_proc
            instance_variable_set(variable_name, value)
          end
        end

        def dsl_list_accessor(list, name, convert: nil)
          variable_name = :"@#{list}"
          setter_name = :"#{list}="
          convert_proc = convert&.to_proc

          define_method(list) do |value = EMPTY|
            if value.equal?(EMPTY)
              instance_variable_get(variable_name)
            else
              instance_variable_set(variable_name, Array(value).dup)
            end
          end

          define_method(name) do |value|
            current = instance_variable_get(variable_name)

            if current
              current.concat(Array(value))
            else
              send(setter_name, value)
            end
          end

          define_method(setter_name) do |value|
            value = if convert_proc
              Array(value).map { |v| convert_proc.call(v) }
            else
              value.dup
            end

            instance_variable_set(variable_name, value)
          end
        end
      end

      refine Object do
        def if_present(value = EMPTY, &block)
          raise(ArgumentError, "Supply either value or block") if !value.equal?(EMPTY) && !block.nil?

          value == EMPTY ? block.call(self) : value
        end
      end

      refine NilClass do
        def if_present(value = EMPTY, &block)
          raise(ArgumentError, "Supply either value or block") if !value.equal?(EMPTY) && !block.nil?

          nil
        end
      end

      refine FalseClass do
        def if_present(value = EMPTY, &block)
          raise(ArgumentError, "Supply either value or block") if !value.equal?(EMPTY) && !block.nil?

          nil
        end
      end

      refine String do
        def if_present(value = EMPTY, &block)
          raise(ArgumentError, "Supply either value or block") if !value.equal?(EMPTY) && !block.nil?

          value == EMPTY ? block.call(self) : value
        end

        def to_pathname
          Pathname.new(self)
        end
      end

      refine Pathname do
        def to_pathname
          self
        end
      end

      refine Array do
        def if_present(value = EMPTY, &block)
          raise(ArgumentError, "Supply either value or block") if !value.equal?(EMPTY) && !block.nil?

          unless empty?
            value == EMPTY ? block.call(self) : value
          end
        end
      end

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
