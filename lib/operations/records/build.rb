# frozen_string_literal: true

require 'operations/records/base'

module Operations::Records
  # Initializes a new record for the given table from the given attributes.
  class Build < Operations::Records::Base
    private

    def process(attributes = {})
      step :handle_invalid_attributes, attributes

      handle_unknown_attribute { record_class.new(attributes) }
    end
  end
end
