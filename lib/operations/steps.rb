# frozen_string_literal: true

require 'operations'

module Operations
  # Step-based process flow for Parchment operations.
  module Steps
    # General-purpose module to include step-based process flow in arbitrary
    # classes or modules.
    module Mixin
      private

      def step(value, *args)
        result = Operations::Steps.extract_result(self, value, args)

        return result.value if result.success?

        throw :cuprum_failed_step, result
      end

      def steps
        result = catch(:cuprum_failed_step) { yield }

        return result.to_cuprum_result if result.respond_to?(:to_cuprum_result)

        Cuprum::Result.new(value: result)
      end
    end

    include Mixin

    class << self
      def extract_result(receiver, value, args)
        return value.to_cuprum_result if value.respond_to?(:to_cuprum_result)

        if value.is_a?(String) || value.is_a?(Symbol)
          return extract_method_result(receiver, value, args)
        end

        message =
          'expected parameter to be a result, an operation, or a method name,' \
          " but was #{value.inspect}"

        raise ArgumentError, message, caller[1..-1]
      end

      private

      def extract_method_result(receiver, value, args)
        result = receiver.send(value, *args)

        return result if result.respond_to?(:to_cuprum_result)

        return receiver.send(:success, result) if receiver.respond_to?(:success)

        Cuprum::Result.new(value: result)
      end
    end

    def call(*args)
      # NOTE: Ivar assignment duplicates logic from Cuprum::Operation, since the
      # module is included *after* the Operation mixin. This resolves an issue
      # when the last value in #process is a failing step.
      #
      # Remove the assignment when defining for generic Cuprum::Command objects.
      # Also remove #to_cuprum_result call and the return of self.
      @result = steps { super }

      self
    end
  end
end
