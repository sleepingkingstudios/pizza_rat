# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/create'

require 'support/examples/operation_examples'

RSpec.describe Operations::Records::Create do
  include Spec::Support::Examples::OperationExamples

  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Spec::Manufacturer }

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

    include_examples 'should validate the attributes'

    include_examples 'should handle invalid attributes',
      lambda {
        it 'should not create the record' do
          expect { call_operation }.not_to change(Spec::Manufacturer, :count)
        end
      }

    describe 'with a hash with valid attributes' do
      let(:attributes) do
        {
          'name'       => 'Umbrella Corp',
          'founded_at' => '1996-03-02'
        }
      end
      let(:expected) do
        super()
          .merge(attributes.stringify_keys)
          .merge(
            'id'         => an_instance_of(Integer),
            'created_at' => an_instance_of(ActiveSupport::TimeWithZone),
            'founded_at' => an_instance_of(ActiveSupport::TimeWithZone)
              .and(
                satisfy do |date|
                  date.to_date.iso8601 == attributes['founded_at']
                end
              ),
            'updated_at' => an_instance_of(ActiveSupport::TimeWithZone)
          )
      end

      it { expect(call_operation).to have_passing_result }

      it { expect(record).to be_a record_class }

      it { expect(record.attributes).to deep_match expected }

      it { expect(record.persisted?).to be true }

      it 'should create the record' do
        expect { call_operation }.to change(Spec::Manufacturer, :count).by(1)
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
