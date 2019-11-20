# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/save'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Save do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Job }

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
          action_required:    false,
          application_active: true,
          application_status: 'interviewing',
          company_name:       'Umbrella Corp',
          data:               {
            'events' => [
              { 'type' => 'viewed_listing' },
              { 'type' => 'application_sent' },
              { 'type' => 'interview_scheduled' }
            ]
          },
          notes:              'BYO-Biohazard Suit',
          source:             'PlayStation',
          source_data:        { 'publisher' => 'Capcom' },
          time_period:        '2020-01',
          title:              'Test Subject'
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
