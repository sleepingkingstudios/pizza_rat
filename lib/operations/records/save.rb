# frozen_string_literal: true

require 'errors/failed_validation'
require 'operations/records/base'

module Operations::Records
  # Validates and persists a record to the database.
  class Save < Operations::Records::Base
    private

    def process(record)
      step :handle_invalid_record, record

      persist_record(record)
    end

    def persist_record(record)
      return record if record.save

      error = Errors::FailedValidation.new(record: record)

      Cuprum::Result.new(error: error, value: record)
    end
  end
end
