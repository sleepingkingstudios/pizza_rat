# frozen_string_literal: true

require 'fixtures/mappings'

module Fixtures::Mappings
  # Abstract mapping that operates on a specific property of each data object.
  class PropertyMapping
    def initialize(property:)
      @property = property.to_s
    end

    attr_reader :property

    def call(data)
      raise ArgumentError, 'data must be a Hash' unless data.is_a?(Hash)

      return data unless data.key?(property)

      old_value = data[property]
      new_value = map_property(data: data, property: property, value: old_value)

      data.merge(property => new_value)
    end

    private

    def map_property(value:, **_kwargs)
      value
    end
  end
end
