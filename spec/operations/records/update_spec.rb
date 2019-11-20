# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/update'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Update do
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

    # rubocop:disable RSpec/RepeatedExample
    include_examples 'should handle invalid attributes',
      lambda {
        it 'should update the attributes' do
          expect { call_operation }
            .to change(record, :attributes)
            .to be >= attributes.stringify_keys
        end

        it { expect { call_operation }.not_to change(record, :persisted?) }
      }

    include_examples 'should handle unknown attributes',
      lambda {
        it { expect { call_operation }.not_to change(record, :attributes) }

        it { expect { call_operation }.not_to change(record, :persisted?) }
      }
    # rubocop:enable RSpec/RepeatedExample

    describe 'with a record with valid attributes' do
      let(:attributes) do
        {
          'action_required'    => false,
          'application_active' => true,
          'application_status' => 'interviewing',
          'company_name'       => 'Umbrella Corp',
          'data'               => {
            'events' => [
              { 'type' => 'viewed_listing' },
              { 'type' => 'application_sent' },
              { 'type' => 'interview_scheduled' }
            ]
          },
          'notes'              => 'BYO-Biohazard Suit',
          'source'             => 'PlayStation',
          'source_data'        => { 'publisher' => 'Capcom' },
          'time_period'        => '2020-01',
          'title'              => 'Test Subject'
        }
      end

      it { expect(call_operation).to have_passing_result.with_value(record) }

      it 'should update the attributes' do
        expect { call_operation }
          .to change(record, :attributes)
          .to be >= attributes
      end

      it { expect { call_operation }.to change(record, :persisted?).to be true }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
