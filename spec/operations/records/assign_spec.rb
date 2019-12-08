# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/assign'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Assign do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Job }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    let(:attributes) { {} }
    let(:expected)   { record_class.new.attributes }
    let(:record)     { record_class.new }

    def call_operation
      operation.call(record, attributes)
    end

    it { expect(operation).to respond_to(:call).with(2).arguments }

    include_examples 'should validate the attributes'

    include_examples 'should validate the record'

    include_examples 'should handle unknown attributes',
      lambda {
        it { expect { call_operation }.not_to change(record, :attributes) }
      }

    describe 'with a hash with valid attributes' do
      let(:attributes) do
        {
          'company_name' => 'Umbrella Corp',
          'source'       => 'PlayStation',
          'time_period'  => '2020-01'
        }
      end
      let(:expected) { super().merge(attributes) }

      it { expect(call_operation).to have_passing_result.with_value(record) }

      it 'should update the attributes' do
        expect { call_operation }
          .to change(record, :attributes)
          .to be >= attributes
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
