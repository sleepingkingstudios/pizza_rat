# frozen_string_literal: true

require 'cuprum/error'

require 'errors'

module Errors
  # Cuprum error for unknown record attributes.
  class UnknownAttributes < Cuprum::Error
    # Format for generating error message.
    MESSAGE = 'Unknown attributes for '

    # Short string used to identify the type of error.
    TYPE = 'unknown_attributes'

    # @param attributes [Array<String>] The names of the unexpected attributes.
    # @param record_class [Class] The class of the expected record.
    def initialize(attributes:, record_class:)
      @attributes   = attributes
      @record_class = record_class

      super(message: generate_message)
    end

    # @return [Array<String>] the names of the unexpected attributes.
    attr_reader :attributes

    # @return [Class] the class of the expected record.
    attr_reader :record_class

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'attributes'   => attributes,
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
      message = MESSAGE + record_class.name

      return message if attributes.empty?

      "#{message}: #{attributes.join(', ')}"
    end
  end
end
