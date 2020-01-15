# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/save'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Save do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Spec::Manufacturer }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    let(:attributes) { {} }
    let(:record)     { record_class.new(attributes) }

    def call_operation
      operation.call(record)
    end

    it { expect(operation).to respond_to(:call).with(1).argument }

    include_examples 'should validate the record'

    include_examples 'should handle invalid attributes',
      lambda {
        it { expect { call_operation }.not_to change(record, :persisted?) }
      }

    describe 'with a record with valid attributes' do
      let(:attributes) do
        {
          'name'       => 'Umbrella Corp',
          'founded_at' => '1996-03-02'
        }
      end

      it { expect(call_operation).to have_passing_result.with_value(record) }

      it { expect { call_operation }.to change(record, :persisted?).to be true }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
