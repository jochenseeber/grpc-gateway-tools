# frozen_string_literal: true

module Protoc
  module Tools
    # Gem extensions
    module StandardExtensions
      EMPTY = Object.new.freeze

      refine Object.singleton_class do
        def dsl_accessor(name)
          name_variable = :"@#{name}"
          default_method = :"default_#{name}"

          define_method(name) do |value = EMPTY|
            if value.equal?(EMPTY)
              result = instance_variable_get(name_variable)

              if result.nil? && respond_to?(default_method)
                send(default_method)
              else
                result
              end
            else
              instance_variable_set(name_variable, value)
            end
          end
        end

        def dsl_list_accessor(list, name)
          list_variable = :"@#{list}"

          define_method(list) do |value = EMPTY|
            if value.equal?(EMPTY)
              instance_variable_get(list_variable)
            else
              instance_variable_set(list_variable, Array(value).dup)
            end
          end

          define_method(name) do |value|
            current = instance_variable_get(list_variable)

            if current
              current.concat(Array(value))
            else
              instance_variable_set(list_variable, Array(value))
            end

            value
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
      end
    end
  end
end
