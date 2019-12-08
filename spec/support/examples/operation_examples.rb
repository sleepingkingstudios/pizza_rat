# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'errors/invalid_parameters'
require 'errors/invalid_record'

require 'support/examples'

module Spec::Support::Examples
  module OperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should handle invalid attributes' do |proc|
      describe 'when the attributes fail validation' do
        let(:attributes) do
          FactoryBot.attributes_for(
            :job,
            company_name: nil,
            source:       '',
            time_period:  'the distant future'
          )
        end
        let(:expected_error) do
          Errors::FailedValidation.new(
            record: record_class.new(attributes).tap(&:valid?)
          )
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end

        instance_exec(&proc) if proc.is_a?(Proc)
      end
    end

    shared_examples 'should handle unknown attributes' do |proc|
      describe 'with an attributes hash with unknown attributes' do
        let(:attributes) do
          {
            'difficulty' => 'high',
            'element'    => 'radiance',
            'explosion'  => 'megacolossal'
          }
        end
        let(:expected_error) do
          Errors::UnknownAttributes.new(
            attributes:   %w[difficulty],
            record_class: record_class
          )
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end

        instance_exec(&proc) if proc.is_a?(Proc)
      end
    end

    shared_examples 'should validate the attributes' do
      describe 'with nil attributes' do
        let(:attributes) { nil }
        let(:expected_error) do
          Errors::InvalidParameters
            .new(errors: [['attributes', 'must be a Hash']])
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end

      describe 'with an attributes Object' do
        let(:attributes) { Object.new }
        let(:expected_error) do
          Errors::InvalidParameters
            .new(errors: [['attributes', 'must be a Hash']])
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end
    end

    shared_examples 'should validate the primary key' do
      describe 'with a nil primary key' do
        let(:id) { nil }
        let(:expected_error) do
          Errors::InvalidParameters
            .new(errors: [['id', "can't be blank"]])
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end

      describe 'with a primary key Object' do
        let(:id) { Object.new }
        let(:expected_error) do
          Errors::InvalidParameters
            .new(errors: [['id', 'must be an Integer']])
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end
    end

    shared_examples 'should validate the record' do
      describe 'with a nil record' do
        let(:record) { nil }
        let(:expected_error) do
          Errors::InvalidRecord.new(record_class: record_class)
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end

      describe 'with a record Object' do
        let(:record) { Object.new }
        let(:expected_error) do
          Errors::InvalidRecord.new(record_class: record_class)
        end

        it 'should have a failing result' do
          expect(call_operation)
            .to have_failing_result.with_error(expected_error)
        end
      end
    end
  end
end
