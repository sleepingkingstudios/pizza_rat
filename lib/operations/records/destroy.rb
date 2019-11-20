# frozen_string_literal: true

require 'operations/records/base'

module Operations::Records
  # Removes a record from the database.
  class Destroy < Operations::Records::Base
    private

    def process(record)
      step :handle_invalid_record, record

      record.tap(&:destroy)
    end
  end
end
