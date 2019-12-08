# frozen_string_literal: true

require 'operations/records'
require 'operations/records/parameter_validations'
require 'operations/steps'

module Operations::Records
  # Abstract base class for record operations.
  class Base < Cuprum::Operation
    include Operations::Records::ParameterValidations
    include Operations::Steps

    class << self
      # Returns a new subclass of the operation that curries the
      #
      # @param record_class [Class] The class of record that the operation's
      #   business logic operates on.
      def subclass(record_class)
        Class.new(self).tap do |klass|
          klass.define_method(:initialize) do |*args|
            super(record_class, *args)
          end

          name = subclass_name(record_class)
          klass.define_singleton_method(:name) { name }
        end
      end

      private

      def subclass_name(record_class)
        *segments, final = name.split('::')

        segments <<
          "#{final.sub(/Operation\z/, '')}#{record_class.name}"

        segments.join('::')
      end
    end

    # @param record_class [Class] The class of record that the operation's
    #   business logic operates on.
    def initialize(record_class)
      @record_class = record_class
    end

    # @return [Class] the class of record that the operation's business logic
    #   operates on.
    attr_reader :record_class
  end
end
