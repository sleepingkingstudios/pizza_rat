# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/destroy'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Destroy do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Spec::Manufacturer }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    let(:record) { nil }

    def call_operation
      operation.call(record)
    end

    it { expect(operation).to respond_to(:call).with(1).argument }

    include_examples 'should validate the record'

    describe 'with a record' do
      let!(:record) { FactoryBot.create(:manufacturer) }

      it { expect(call_operation).to have_passing_result.with_value(record) }

      it 'should reduce the record count' do
        expect { call_operation }.to change(Spec::Manufacturer, :count).by(-1)
      end

      it 'should destroy the record' do
        expect { call_operation }.to change(record, :persisted?).to be false
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
