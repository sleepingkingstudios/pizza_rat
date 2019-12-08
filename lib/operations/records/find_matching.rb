# frozen_string_literal: true

require 'operations/records/base'

module Operations::Records
  # Queries the database for records in the given table matching the specified
  # criteria.
  class FindMatching < Operations::Records::Base
    private

    def build_query(order:)
      record_class
        .all
        .order(order)
    end

    def default_order
      { created_at: :desc }
    end

    def process(order: nil)
      order = default_order if order.blank?
      query = build_query(order: order)

      query.to_a
    end
  end
end
