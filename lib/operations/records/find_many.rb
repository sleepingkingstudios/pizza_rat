# frozen_string_literal: true

require 'operations/records/base'
require 'operations/records/parameter_validations'

module Operations::Records
  # Queries the database for the records in the given table with the given
  # primary keys.
  class FindMany < Operations::Records::Base
    include Operations::Records::ParameterValidations::Many

    private

    def find_records(ids, allow_partial:)
      records   = record_class.where(id: ids).to_a
      not_found = ids - records.map(&:id)

      return records if allow_partial || not_found.empty?

      failure(not_found_error(not_found))
    end

    def not_found_error(ids)
      Errors::NotFound.new(
        attributes:   { ids: ids },
        record_class: record_class
      )
    end

    # @param ids [Array] The ids to query.
    # @param allow_partial [Boolean] If false, then the operation will return a
    #   failing result unless records are found for all of the input ids.
    #   Defaults to false.
    def process(ids, allow_partial: false)
      step :handle_nil_ids_array,          ids
      step :handle_ids_array_type_invalid, ids
      step :handle_empty_ids_array,        ids

      ids.each.with_index do |id, index|
        step :handle_nil_id,          id, index
        step :handle_id_type_invalid, id, index
      end

      find_records(ids, allow_partial: allow_partial)
    end
  end
end
