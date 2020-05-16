# frozen_string_literal: true

require "os"
require "pathname"

module Protoc
  module Tools
    # Gem extensions
    module CoreExtensions
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

      refine Class do
        def descendants
          descendants = []

          ObjectSpace.each_object(singleton_class) do |cls|
            descendants << cls if !cls.singleton_class? && !cls.equal?(self)
          end

          descendants
        end
      end
    end
  end
end
