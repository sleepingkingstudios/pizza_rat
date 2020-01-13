# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/find_matching'

RSpec.describe Operations::Records::FindMatching do
  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Spec::Manufacturer }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    def call_operation(options = {})
      operation.call(**options)
    end

    it { expect(operation).to respond_to(:call).with(1).argument }

    it { expect(call_operation).to have_passing_result.with_value([]) }

    context 'when there are many records' do
      let(:record_attributes) do
        [
          { name: 'Weyland-Yutani',  created_at: 1.day.ago },
          { name: 'Umbrella Corp',   created_at: 3.days.ago },
          { name: 'Raccoon City PD', created_at: 2.days.ago }
        ]
      end
      let!(:records) do
        record_attributes.map { |hsh| FactoryBot.create(:manufacturer, hsh) }
      end
      let(:expected) do
        records.sort_by(&:created_at).reverse
      end

      it 'should find the matching records and sort by created_at' do
        expect(call_operation)
          .to have_passing_result
          .with_value(expected)
      end

      describe 'with order: empty Hash' do
        let(:options) { { order: {} } }

        it 'should find the matching records and sort by created_at' do
          expect(call_operation options)
            .to have_passing_result
            .with_value(expected)
        end
      end

      describe 'with order: Hash' do
        let(:order)   { { name: :asc } }
        let(:options) { { order: order } }
        let(:expected) do
          records.sort_by(&:name)
        end

        it 'should find the matching records and apply the ordering' do
          expect(call_operation options)
            .to have_passing_result
            .with_value(expected)
        end
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
