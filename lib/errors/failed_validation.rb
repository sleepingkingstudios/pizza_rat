# frozen_string_literal: true

require 'cuprum/error'

require 'errors'

module Errors
  # Cuprum error for a record with validation errors.
  class FailedValidation < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'failed_validation'

    # @param record [ApplicationRecord] The record with validation errors.
    def initialize(record:)
      @errors       = format_errors(record)
      @record_class = record.class

      super(message: generate_message)
    end

    # @return [Array<Array>] the validation errors.
    attr_reader :errors

    # @return [Class] the class of the record with validation errors.
    attr_reader :record_class

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'errors'       => errors,
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

    def format_errors(record)
      record.errors.entries.map { |(key, message)| [key.to_s, message] }
    end

    def generate_message
      message = "#{record_class.name} has validation errors"

      return message if errors.empty?

      "#{message}: #{errors.map { |ary| ary.join(' ') }.join(', ')}"
    end
  end
end
