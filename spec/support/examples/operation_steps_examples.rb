# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module OperationStepsExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should execute the steps' do
      context 'when the implementation has a failing step' do
        let(:error) do
          Cuprum::Error.new(message: 'Something went wrong.')
        end
        let(:implementation) do
          err = error

          -> { step Cuprum::Result.new(error: err) }
        end

        it 'should return the failing result' do
          expect(result).to be_a_failing_result.with_error(be == error)
        end
      end

      context 'when the implementation has a passing step' do
        let(:implementation) do
          -> { step Cuprum::Result.new(value: 'result value') }
        end

        it 'should return the passing result' do
          expect(result).to be_a_passing_result.with_value(be == 'result value')
        end
      end

      context 'when the implementation has multiple failing steps' do
        let(:error) do
          Cuprum::Error.new(message: 'Something went wrong.')
        end
        let(:implementation) do
          err = error

          lambda do
            step Cuprum::Result.new(error: err)
            # :nocov:
            step Cuprum::Result.new(
              error: Cuprum::Error.new(message: 'Something else went wrong.')
            )
            step Cuprum::Result.new(
              error: Cuprum::Error.new(message: 'Everything went wrong.')
            )
            # :nocov:
          end
        end

        it 'should return the first failing result' do
          expect(result).to be_a_failing_result.with_error(be == error)
        end
      end

      context 'when the implementation has mixed passing and failing steps' do
        let(:error) do
          Cuprum::Error.new(message: 'Something went wrong.')
        end
        let(:implementation) do
          err = error

          lambda do
            step Cuprum::Result.new(value: 'initial value')
            step Cuprum::Result.new(error: err)
            # :nocov:
            step Cuprum::Result.new(value: 'later value')
            step success('later value')
            step Cuprum::Result.new(
              error: Cuprum::Error.new(message: 'Something else went wrong.')
            )
            # :nocov:
          end
        end

        it 'should return the result from the first failing step' do
          expect(result).to be_a_failing_result.with_error(be == error)
        end
      end

      context 'when the implementation has multiple passing steps' do
        let(:widget_id) { 0 }
        let(:implementation) do
          id = widget_id

          lambda do
            step :validate_parameters

            widget       = step :find_resource,    id
            manufacturer = step :find_association, widget[:manufacturer_id]

            format_response(widget: widget, manufacturer: manufacturer)
          end
        end
        let(:expected) do
          {
            ok:   true,
            data: {
              manufacturer: { name: 'Brooklyn Widget Factory' },
              widget:       {
                name:            'Self-sealing Stem Bolt',
                manufacturer_id: 1
              }
            }
          }
        end

        before(:example) do
          described_class.define_method(:validate_parameters) {}

          described_class.define_method(:find_resource) do |_id|
            { name: 'Self-sealing Stem Bolt', manufacturer_id: 1 }
          end

          described_class.define_method(:find_association) do |_association_id|
            { name: 'Brooklyn Widget Factory' }
          end

          described_class.define_method(:format_response) do |data|
            { ok: true, data: data }
          end

          %i[
            find_association
            find_resource
            format_response
            validate_parameters
          ].each do |method_name|
            allow(subject).to receive(method_name).and_call_original
          end
        end

        it 'should return the final passing result' do
          expect(result).to be_a_passing_result.with_value(be == expected)
        end

        # rubocop:disable RSpec/ExampleLength
        # rubocop:disable RSpec/MultipleExpectations
        it 'should perform each step in sequence' do
          run_steps

          expect(subject).to have_received(:validate_parameters).ordered
          expect(subject).to have_received(:find_resource).with(0).ordered
          expect(subject).to have_received(:find_association).with(1).ordered
          expect(subject).to have_received(:format_response)
            .with(expected[:data])
            .ordered
        end
        # rubocop:enable RSpec/ExampleLength
        # rubocop:enable RSpec/MultipleExpectations
      end
    end

    shared_examples 'should implement the Steps methods' do
      describe '#step' do
        it 'should define the private method' do
          expect(subject)
            .to respond_to(:step, true)
            .with(1).argument
            .and_unlimited_arguments
        end

        describe 'with nil' do
          let(:error_message) do
            'expected parameter to be a result, an operation, or a method' \
            ' name, but was nil'
          end

          it 'should raise an error' do
            expect { subject.send(:step, nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a value' do
          let(:value) { Object.new.freeze }
          let(:error_message) do
            'expected parameter to be a result, an operation, or a method' \
            " name, but was #{value.inspect}"
          end

          it 'should raise an error' do
            expect { subject.send(:step, value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with the name of an undefined method' do
          it 'should raise an error' do
            expect { subject.send(:step, :do_nothing) }
              .to raise_error NoMethodError
          end
        end

        describe 'with the name of a method that returns a non-result value' do
          let(:value) { 'returned value' }

          before(:example) do
            allow(subject).to receive(:do_something).and_return(value)
          end

          it 'should call the method' do
            subject.send(:step, :do_something)

            expect(subject).to have_received(:do_something).with(no_args)
          end

          it 'should return the result value' do
            expect(subject.send(:step, :do_something)).to be value
          end
        end

        describe 'with the name of a method that returns a failing result' do
          let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
          let(:result) { Cuprum::Result.new(error: error) }

          before(:example) do
            allow(subject).to receive(:do_something).and_return(result)
          end

          it 'should call the method' do
            catch(:cuprum_failed_step) { subject.send(:step, :do_something) }

            expect(subject).to have_received(:do_something).with(no_args)
          end

          it 'should throw :cuprum_failed_step and the failing result' do
            expect { subject.send(:step, :do_something) }
              .to throw_symbol(:cuprum_failed_step, result)
          end
        end

        describe 'with the name of a method that returns a passing result' do
          let(:value)  { 'result value' }
          let(:result) { Cuprum::Result.new(value: value) }

          before(:example) do
            allow(subject).to receive(:do_something).and_return(result)
          end

          it 'should call the method' do
            subject.send(:step, :do_something)

            expect(subject).to have_received(:do_something).with(no_args)
          end

          it 'should return the result value' do
            expect(subject.send(:step, :do_something)).to be value
          end
        end

        describe 'with the name of a method that takes arguments' do
          let(:arguments) { %w[ichi ni san] }
          let(:value)     { 'result value' }
          let(:result)    { Cuprum::Result.new(value: value) }

          before(:example) do
            allow(subject).to receive(:do_something).and_return(result)
          end

          it 'should call the method' do
            subject.send(:step, :do_something, *arguments)

            expect(subject).to have_received(:do_something).with(*arguments)
          end

          it 'should return the result value' do
            expect(subject.send(:step, :do_something)).to be value
          end
        end

        describe 'with an uncalled operation' do
          let(:other)  { Cuprum::Operation.new }
          let(:result) { other.to_cuprum_result }

          it 'should throw :cuprum_failed_step and the failing result' do
            expect { subject.send(:step, other) }
              .to throw_symbol(:cuprum_failed_step, result)
          end
        end

        describe 'with a called operation with a failing result' do
          let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
          let(:result) { Cuprum::Result.new(error: error) }
          let(:other) do
            returned_result = result

            Cuprum::Operation.new { returned_result }.call
          end

          it 'should throw :cuprum_failed_step and the failing result' do
            expect { subject.send(:step, other) }
              .to throw_symbol(:cuprum_failed_step, result)
          end
        end

        describe 'with a called operation with a passing result' do
          let(:value)  { 'result value' }
          let(:result) { Cuprum::Result.new(value: value) }
          let(:other) do
            returned_result = result

            Cuprum::Operation.new { returned_result }.call
          end

          it 'should return the result value' do
            expect(subject.send(:step, other)).to be value
          end
        end

        describe 'with a failing result' do
          let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
          let(:result) { Cuprum::Result.new(error: error) }

          it 'should throw :cuprum_failed_step and the failing result' do
            expect { subject.send(:step, result) }
              .to throw_symbol(:cuprum_failed_step, result)
          end
        end

        describe 'with a passing result' do
          let(:value)  { 'result value' }
          let(:result) { Cuprum::Result.new(value: value) }

          it 'should return the result value' do
            expect(subject.send(:step, result)).to be value
          end
        end
      end

      describe '#steps' do
        let(:implementation) { -> {} }
        let(:result)         { run_steps }

        def run_steps
          subject.send(:steps) { subject.instance_exec(&implementation) }
        end

        it 'should define the private method' do
          expect(subject).to respond_to(:steps, true).with(0).arguments
        end

        include_examples 'should execute the steps'
      end
    end
  end
end
