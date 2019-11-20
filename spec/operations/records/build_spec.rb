# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/build'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Build do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Job }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    let(:attributes) { nil }
    let(:expected)   { record_class.new.attributes }
    let(:record)     { call_operation.value }

    def call_operation
      operation.call(attributes)
    end

    it { expect(operation).to respond_to(:call).with(0..1).arguments }

    describe 'with no arguments' do
      def call_operation
        operation.call
      end

      it { expect(call_operation).to have_passing_result }

      it { expect(record).to be_a record_class }

      it { expect(record.attributes).to be == expected }
    end

    include_examples 'should validate the attributes'

    include_examples 'should handle unknown attributes'

    describe 'with an empty hash' do
      let(:attributes) { {} }

      it { expect(call_operation).to have_passing_result }

      it { expect(record).to be_a record_class }

      it { expect(record.attributes).to be == expected }
    end

    describe 'with a hash with valid attributes' do
      let(:attributes) do
        {
          'company_name' => 'Umbrella Corp',
          'source'       => 'PlayStation',
          'time_period'  => '2020-01'
        }
      end
      let(:expected) { super().merge(attributes) }

      it { expect(call_operation).to have_passing_result }

      it { expect(record).to be_a record_class }

      it { expect(record.attributes).to be == expected }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
