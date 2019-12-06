# frozen_string_literal: true

require 'support/matchers'

module Spec::Support::Matchers
  class CallCommandStepMatcher # rubocop:disable Metrics/ClassLength
    include RSpec::Mocks::ExampleMethods

    def initialize(receiver, method_name = nil)
      @expected_arguments = nil
      @original_receiver  = receiver

      initialize_with_params(method_name: method_name, receiver: receiver)
    end

    attr_reader :expected_arguments

    attr_reader :expected_method

    attr_reader :expected_receiver

    def description
      str = +'call command step'
      str << ' ' << step_name if step_name
      str << ' with arguments ' << format_arguments if expected_arguments?

      str
    end

    def does_not_match?(actual)
      if expected_arguments?
        raise 'expect {}.not_to call_command_step.with_arguments is not' \
              ' supported'
      end

      stub_receiver

      actual.call

      !step_called?
    end

    def failure_message
      return failure_message_for_step unless step_called?

      return failure_message_for_arguments unless arguments_match?

      return failure_message_for_result unless result_matches?

      # :nocov:
      "expected the block to #{description}"
      # :nocov:
    end

    def failure_message_when_negated
      str = +'expected the block not to call command step'
      str << ' ' << step_name if step_name
      str
    end

    def matches?(actual)
      stub_receiver

      @actual_result = actual.call

      step_called? && arguments_match? && result_matches?
    end

    def supports_block_expectations?
      true
    end

    def with_arguments(*args)
      @expected_arguments = args

      self
    end

    private

    attr_reader :actual_result

    attr_reader :original_receiver

    def arguments_match?
      return true unless expected_arguments?

      return @arguments_match unless @arguments_match.nil?

      @arguments_match = arguments_matcher.matches?(expected_receiver) || false
    end

    def arguments_matcher
      @arguments_matcher ||=
        have_received(expected_method).with(*expected_arguments)
    end

    def command_class?(object)
      object.is_a?(Class) && object < Cuprum::Command
    end

    def expected_arguments?
      !(expected_arguments.nil? || expected_arguments.empty?)
    end

    def failure_message_for_arguments
      str =
        +"expected the block to #{description}, but the method was called" \
         ' with invalid arguments'

      arguments_matcher.failure_message.split("\n")[1..-1].each do |line|
        str << "\n" << line
      end

      str
    end

    def failure_message_for_result
      "expected the block to #{description}, but a failing result was ignored"
    end

    def failure_message_for_step
      str =
        +"expected the block to #{description}, but the method was not called"

      have_received_matcher.failure_message.split("\n")[1..-1].each do |line|
        str << "\n" << line
      end

      str
    end

    def failure_result
      return @failure_result if @failure_result

      error = Cuprum::Error.new(message: 'Something went wrong')

      @failure_result = Cuprum::Result.new(error: error)
    end

    def format_arguments
      return '' if expected_arguments.empty?

      expected_arguments.map(&:inspect).join ', '
    end

    def have_received_matcher
      @have_received_matcher ||= have_received(expected_method)
    end

    def initialize_with_class(command_class:)
      command = instance_double(command_class, call: nil)

      allow(command_class).to receive(:new).and_return(command)

      @expected_method   = :call
      @expected_receiver = command
    end

    def initialize_with_instance(command:)
      @expected_method   = :call
      @expected_receiver = command
    end

    def initialize_with_method(method_name:, receiver:)
      unless method_name.is_a?(String) || method_name.is_a?(Symbol)
        raise ArgumentError, invalid_constructor_arguments, caller[1..-1]
      end

      @expected_method   = method_name
      @expected_receiver = receiver
    end

    def initialize_with_params(method_name:, receiver:)
      if method_name
        initialize_with_method(method_name: method_name, receiver: receiver)
      elsif command_class?(receiver)
        initialize_with_class(command_class: receiver)
      elsif receiver.is_a?(Cuprum::Command)
        initialize_with_instance(command: receiver)
      else
        raise ArgumentError, invalid_constructor_arguments
      end
    end

    def invalid_constructor_arguments
      'must provide an operation class, an operation instance, or a receiver' \
      ' and a method name'
    end

    def result_matches?
      return @result_matches unless @result_matches.nil?

      @result_matches = (actual_result == failure_result)
    end

    def step_called?
      return @step_called unless @step_called.nil?

      @step_called = have_received_matcher.matches?(expected_receiver) || false
    end

    def step_name
      return expected_method.inspect unless expected_method == :call

      original_receiver.inspect
    end

    def stub_receiver
      allow(expected_receiver)
        .to receive(expected_method)
        .and_return(failure_result)
    end
  end
end
