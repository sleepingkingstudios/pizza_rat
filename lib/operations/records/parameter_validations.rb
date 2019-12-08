# frozen_string_literal: true

require 'errors/invalid_parameters'
require 'errors/invalid_record'
require 'errors/not_found'
require 'errors/unknown_attributes'
require 'operations/records'
require 'operations/steps'

module Operations::Records
  # Shared methods for validating parameters to an operation.
  module ParameterValidations
    # Shared methods for validating plural primary/foreign key arguments.
    module Many
      def handle_empty_ids_array(ids)
        return unless ids.empty?

        error = Errors::InvalidParameters.new(
          errors: [['ids', "can't be blank"]]
        )

        failure(error)
      end

      def handle_id_type_invalid(id, index)
        return if id.is_a?(Integer)

        error = Errors::InvalidParameters.new(
          errors: [["ids.#{index}", 'must be an Integer']]
        )

        failure(error)
      end

      def handle_ids_array_type_invalid(ids)
        return if ids.is_a?(Array)

        error = Errors::InvalidParameters.new(
          errors: [['ids', 'must be an Array']]
        )

        failure(error)
      end

      def handle_nil_id(id, index)
        return unless id.nil?

        error = Errors::InvalidParameters.new(
          errors: [["ids.#{index}", "can't be blank"]]
        )

        failure(error)
      end

      def handle_nil_ids_array(ids)
        return unless ids.nil?

        error = Errors::InvalidParameters.new(
          errors: [['ids', "can't be blank"]]
        )

        failure(error)
      end
    end

    # Shared methods for validating singular primary/foreign key arguments.
    module One
      include Operations::Steps

      def handle_id_type_invalid(id, as: :id)
        return if id.is_a?(Integer)

        error = Errors::InvalidParameters.new(
          errors: [[as.to_s, 'must be an Integer']]
        )

        failure(error)
      end

      def handle_invalid_id(id, as: :id)
        steps do
          step :handle_nil_id,          id, as: as
          step :handle_id_type_invalid, id, as: as
        end
      end

      def handle_nil_id(id, as: :id)
        return unless id.nil?

        error = Errors::InvalidParameters.new(
          errors: [[as.to_s, "can't be blank"]]
        )

        failure(error)
      end
    end

    private

    def handle_invalid_attributes(attributes)
      return if attributes.is_a?(Hash)

      error = Errors::InvalidParameters.new(
        errors: [['attributes', 'must be a Hash']]
      )

      failure(error)
    end

    def handle_invalid_record(record)
      return if record.is_a?(record_class)

      error = Errors::InvalidRecord.new(record_class: record_class)

      failure(error)
    end

    def handle_unknown_attribute
      yield
    rescue ActiveModel::UnknownAttributeError => exception
      error = Errors::UnknownAttributes.new(
        attributes:   [unknown_attribute_name(exception)],
        record_class: record_class
      )

      failure(error)
    end

    def unknown_attribute_name(exception)
      unknown_attribute_pattern.match(exception.message)['attribute_name']
    end

    def unknown_attribute_pattern
      /unknown attribute '(?<attribute_name>.*)'/
    end
  end
end
