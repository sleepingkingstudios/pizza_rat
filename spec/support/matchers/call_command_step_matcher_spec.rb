# frozen_string_literal: true

require 'support/matchers/call_command_step_matcher'

RSpec.describe Spec::Support::Matchers::CallCommandStepMatcher do
  shared_context 'when initialized with a command class' do
    subject(:matcher) { described_class.new(receiver) }

    let(:receiver) { Spec::InnerCommand }
    let(:process_and_return_other) do
      lambda do
        Spec::InnerCommand.new.call

        Cuprum::Result.new
      end
    end
    let(:process_with_invalid_args) do
      -> { Spec::InnerCommand.new.call }
    end
    let(:process_with_valid_args) do
      step_args = defined?(expected_arguments) ? expected_arguments : []

      -> { Spec::InnerCommand.new.call(*step_args) }
    end

    example_class 'Spec::CustomCommand', Cuprum::Command

    example_class 'Spec::InnerCommand', Cuprum::Command
  end

  shared_context 'when initialized with a command instance' do
    subject(:matcher) { described_class.new(receiver) }

    let(:receiver) { Spec::InnerCommand.new }

    example_class 'Spec::CustomCommand', Cuprum::Command

    example_class 'Spec::InnerCommand', Cuprum::Command

    let(:process_and_return_other) do
      command = receiver

      lambda do
        command.call

        Cuprum::Result.new
      end
    end
    let(:process_with_invalid_args) do
      command = receiver

      -> { command.call }
    end
    let(:process_with_valid_args) do
      command   = receiver
      step_args = defined?(expected_arguments) ? expected_arguments : []

      -> { command.call(*step_args) }
    end
  end

  shared_context 'when initialized with a method name and a receiver' do
    subject(:matcher) { described_class.new(receiver, method_name) }

    let(:receiver)    { Spec::CustomCommand.new }
    let(:method_name) { :custom_step }
    let(:process_and_return_other) do
      step_name = method_name

      lambda do
        send(step_name)

        Cuprum::Result.new
      end
    end
    let(:process_with_invalid_args) do
      step_name = method_name

      -> { send(step_name) }
    end
    let(:process_with_valid_args) do
      step_name = method_name
      step_args = defined?(expected_arguments) ? expected_arguments : []

      -> { send(step_name, *step_args) }
    end

    example_class 'Spec::CustomCommand', Cuprum::Command do |klass|
      klass.define_method(:custom_step) { |*_args| }
    end
  end

  shared_context 'with an arguments expectation' do
    let(:expected_arguments) { %w[ichi ni san] }
    let(:matcher)            { super().with_arguments(*expected_arguments) }
  end

  subject(:matcher) { described_class.new(receiver) }

  let(:receiver)    { Cuprum::Command.new }
  let(:method_name) { nil }

  describe '::new' do
    let(:error_message) do
      'must provide an operation class, an operation instance, or a receiver' \
      ' and a method name'
    end

    it 'should define the constructor' do
      expect(described_class).to be_constructible.with(1..2).arguments
    end

    describe 'with an invalid method name' do
      let(:method_name) { Object.new.freeze }

      it 'should raise an exception' do
        expect { described_class.new receiver, method_name }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an invalid receiver' do
      let(:receiver) { Object.new.freeze }

      it 'should raise an exception' do
        expect { described_class.new receiver }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#description' do
    include_examples 'should have reader', :description

    wrap_context 'when initialized with a command class' do
      let(:expected) { "call command step #{receiver.inspect}" }

      it { expect(matcher.description).to be == expected }

      wrap_context 'with an arguments expectation' do
        let(:expected) do
          formatted_args = expected_arguments.map(&:inspect).join ', '

          super() + " with arguments #{formatted_args}"
        end

        it { expect(matcher.description).to be == expected }
      end
    end

    wrap_context 'when initialized with a command instance' do
      let(:expected) { "call command step #{receiver.inspect}" }

      it { expect(matcher.description).to be == expected }

      wrap_context 'with an arguments expectation' do
        let(:expected) do
          formatted_args = expected_arguments.map(&:inspect).join ', '

          super() + " with arguments #{formatted_args}"
        end

        it { expect(matcher.description).to be == expected }
      end
    end

    wrap_context 'when initialized with a method name and a receiver' do
      let(:expected) { "call command step #{method_name.inspect}" }

      it { expect(matcher.description).to be == expected }

      wrap_context 'with an arguments expectation' do
        let(:expected) do
          formatted_args = expected_arguments.map(&:inspect).join ', '

          super() + " with arguments #{formatted_args}"
        end

        it { expect(matcher.description).to be == expected }
      end
    end
  end

  describe '#does_not_match?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(strip_oids(matcher.failure_message_when_negated))
          .to be == strip_oids(failure_message)
      end
    end

    shared_examples 'should assert that the step was not called' do
      describe 'with an empty block' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> {} }

        it { expect(matcher.does_not_match? actual).to be true }
      end

      describe 'with a block that does not call the command' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { 'greetings, programs!'.capitalize } }

        it { expect(matcher.does_not_match? actual).to be true }
      end

      context 'when the command raise an exception' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(:process) do
            raise 'Something went wrong'
          end
        end

        it 'should raise the exception' do
          expect { matcher.does_not_match? actual }
            .to raise_exception RuntimeError, 'Something went wrong'
        end
      end

      context 'when the command does not call the step' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(:process) {}
        end

        it { expect(matcher.does_not_match? actual).to be true }
      end

      context 'when the command calls the step but does not return the result' \
      do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(
            :process,
            &process_and_return_other
          )
        end

        it { expect(matcher.does_not_match? actual).to be false }

        include_examples 'should set the failure message'
      end

      context 'when the command calls the step' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(
            :process,
            &process_with_invalid_args
          )
        end

        it { expect(matcher.does_not_match? actual).to be false }

        include_examples 'should set the failure message'
      end

      wrap_context 'with an arguments expectation' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> {} }
        let(:error_message) do
          'expect {}.not_to call_command_step.with_arguments is not supported'
        end

        it 'should raise an exception' do
          expect { matcher.does_not_match? actual }
            .to raise_exception RuntimeError, error_message
        end
      end
    end

    let(:description)     { 'call command step' }
    let(:failure_message) { "expected the block not to #{description}" }

    def strip_oids(str)
      str&.gsub(/:0x[0-9a-f]{16}/, '')
    end

    it { expect(matcher).to respond_to(:does_not_match?).with(1).argument }

    wrap_context 'when initialized with a command class' do
      let(:description) { "call command step #{receiver.inspect}" }

      include_examples 'should assert that the step was not called'
    end

    wrap_context 'when initialized with a command instance' do
      let(:description) { "call command step #{receiver.inspect}" }

      include_examples 'should assert that the step was not called'
    end

    wrap_context 'when initialized with a method name and a receiver' do
      let(:description) { "call command step #{method_name.inspect}" }
      let(:receiver)    { command }

      include_examples 'should assert that the step was not called'
    end
  end

  describe '#expected_arguments' do
    include_examples 'should have reader', :expected_arguments, nil

    wrap_context 'with an arguments expectation' do
      it { expect(matcher.expected_arguments).to be == expected_arguments }
    end
  end

  describe '#expected_method' do
    include_examples 'should have reader', :expected_method

    wrap_context 'when initialized with a command class' do
      it { expect(matcher.expected_method).to be :call }
    end

    wrap_context 'when initialized with a command instance' do
      it { expect(matcher.expected_method).to be :call }
    end

    wrap_context 'when initialized with a method name and a receiver' do
      it { expect(matcher.expected_method).to be method_name }
    end
  end

  describe '#expected_receiver' do
    include_examples 'should have reader', :expected_receiver

    wrap_context 'when initialized with a command class' do
      it 'should create a double' do
        expect(matcher.expected_receiver)
          .to be_a RSpec::Mocks::InstanceVerifyingDouble
      end

      it 'should stub out the command class constructor' do
        expect(matcher.expected_receiver).to be receiver.new
      end
    end

    wrap_context 'when initialized with a command instance' do
      it { expect(matcher.expected_receiver).to be receiver }
    end

    wrap_context 'when initialized with a method name and a receiver' do
      it { expect(matcher.expected_receiver).to be receiver }
    end
  end

  describe '#failure_message' do
    it { expect(matcher).to respond_to(:failure_message).with(0).arguments }
  end

  describe '#failure_message_when_negated' do
    it 'should define the method' do
      expect(matcher)
        .to respond_to(:failure_message_when_negated)
        .with(0).arguments
    end
  end

  describe '#matches?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(strip_oids(matcher.failure_message))
          .to be == strip_oids(failure_message)
      end
    end

    shared_examples 'should assert that the step was called' do
      describe 'with an empty block' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> {} }
        let(:failure_message) do
          super() +
            ', but the method was not called' \
            "\n    expected: 1 time with any arguments" \
            "\n    received: 0 times with any arguments"
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a block that does not call the command' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { 'greetings, programs!'.capitalize } }
        let(:failure_message) do
          super() +
            ', but the method was not called' \
            "\n    expected: 1 time with any arguments" \
            "\n    received: 0 times with any arguments"
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      context 'when the command raise an exception' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(:process) do
            raise 'Something went wrong'
          end
        end

        it 'should raise the exception' do
          expect { matcher.matches? actual }
            .to raise_exception RuntimeError, 'Something went wrong'
        end
      end

      context 'when the command does not call the step' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }
        let(:failure_message) do
          super() +
            ', but the method was not called' \
            "\n    expected: 1 time with any arguments" \
            "\n    received: 0 times with any arguments"
        end

        before(:example) do
          Spec::CustomCommand.define_method(:process) {}
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      context 'when the command calls the step but does not return the result' \
      do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }
        let(:failure_message) do
          super() + ', but a failing result was ignored'
        end

        before(:example) do
          Spec::CustomCommand.define_method(
            :process,
            &process_and_return_other
          )
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      context 'when the command calls the step' do
        let(:command) { Spec::CustomCommand.new }
        let(:actual)  { -> { command.call } }

        before(:example) do
          Spec::CustomCommand.define_method(
            :process,
            &process_with_invalid_args
          )
        end

        it { expect(matcher.matches? actual).to be true }
      end

      wrap_context 'with an arguments expectation' do
        let(:description) do
          formatted_args = expected_arguments.map(&:inspect).join ', '

          super() + " with arguments #{formatted_args}"
        end

        context 'when the command calls the step with invalid arguments' do
          let(:command) { Spec::CustomCommand.new }
          let(:actual)  { -> { command.call } }
          let(:failure_message) do
            super() +
              ', but the method was called with invalid arguments' \
              "\n  expected: (\"ichi\", \"ni\", \"san\")" \
              "\n       got: (no args)"
          end

          before(:example) do
            Spec::CustomCommand.define_method(
              :process,
              &process_with_invalid_args
            )
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        context 'when the command calls the step with valid arguments' do
          let(:command) { Spec::CustomCommand.new }
          let(:actual)  { -> { command.call } }

          before(:example) do
            Spec::CustomCommand.define_method(
              :process,
              &process_with_valid_args
            )
          end

          it { expect(matcher.matches? actual).to be true }
        end
      end
    end

    let(:description)     { 'call command step' }
    let(:failure_message) { "expected the block to #{description}" }

    def strip_oids(str)
      str.gsub(/:0x[0-9a-f]{16}/, '')
    end

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    wrap_context 'when initialized with a command class' do
      let(:description) { "call command step #{receiver.inspect}" }

      include_examples 'should assert that the step was called'
    end

    wrap_context 'when initialized with a command instance' do
      let(:description) { "call command step #{receiver.inspect}" }

      include_examples 'should assert that the step was called'
    end

    wrap_context 'when initialized with a method name and a receiver' do
      let(:description) { "call command step #{method_name.inspect}" }
      let(:receiver)    { command }

      include_examples 'should assert that the step was called'
    end
  end

  describe '#supports_block_expectations?' do
    include_examples 'should define predicate',
      :supports_block_expectations?,
      true
  end

  describe '#with_arguments' do
    it 'should define the method' do
      expect(matcher).to respond_to(:with_arguments).with_unlimited_arguments
    end

    it { expect(matcher.with_arguments 'ichi', 'ni', 'san').to be matcher }
  end
end
