# frozen_string_literal: true

require 'cuprum/error'

require 'errors'

module Errors
  # Cuprum error for a record not found.
  class NotFound < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'not_found'

    # @param attributes [Hash<String, Object>] The expected attributes.
    # @param record_class [Class] The class of the expected record.
    def initialize(attributes:, record_class:)
      @attributes   = attributes
      @record_class = record_class

      super(message: generate_message)
    end

    # @return [Hash<String, Object>] the expected attributes.
    attr_reader :attributes

    # @return [Class] the class of the expected record.
    attr_reader :record_class

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'attributes'   => attributes.stringify_keys,
          'record_class' => record_class.name
        },
        'message' => message,
        'type'    => type
      }
    end

    # @return [String] short string used to identify the type of error.
    def type
      TYPE
    end

    private

    def generate_message
      message = "#{record_class.name} not found"

      return message if attributes.empty?

      "#{message} with attributes" \
      " #{attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}"
    end
  end
end
