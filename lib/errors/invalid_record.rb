# frozen_string_literal: true

require 'cuprum/error'

require 'errors'

module Errors
  # Cuprum error for an invalid record argument.
  class InvalidRecord < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'invalid_record'

    # @param record_class [Class] The class of the expected record.
    def initialize(record_class:)
      @record_class = record_class

      super(message: "Record should be a #{record_class.name}")
    end

    # @return [Class] the class of the expected record.
    attr_reader :record_class

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
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
  end
end
