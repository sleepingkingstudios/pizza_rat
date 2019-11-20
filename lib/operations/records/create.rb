# frozen_string_literal: true

require 'operations/records/build'
require 'operations/records/save'

module Operations::Records
  # Initializes a new record for the given table from the given attributes,
  # validates the record, and persists it to the database.
  class Create < Operations::Records::Build
    def initialize(record_class, build_operation: nil, save_operation: nil)
      super(record_class)

      @build_operation =
        build_operation || Operations::Records::Build.new(record_class)
      @save_operation =
        save_operation  || Operations::Records::Save.new(record_class)
    end

    private

    attr_reader :build_operation

    attr_reader :save_operation

    def process(attributes = {})
      record = step build_operation.call(attributes)

      save_operation.call(record)
    end
  end
end
