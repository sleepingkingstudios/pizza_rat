# frozen_string_literal: true

require 'rails_helper'

require 'errors/failed_validation'

RSpec.describe Errors::FailedValidation do
  subject(:error) { described_class.new(record: record) }

  let(:attributes)   { FactoryBot.attributes_for(:job, company_name: nil) }
  let(:record_class) { Job }
  let(:record)       { record_class.new(attributes).tap(&:valid?) }

  describe '::TYPE' do
    include_examples 'should define constant', :TYPE, 'failed_validation'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:record)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'errors'       => [['company_name', "can't be blank"]],
          'record_class' => record_class.name
        },
        'message' => error.message,
        'type'    => described_class::TYPE
      }
    end

    it { expect(error).to respond_to(:as_json).with(0).arguments }

    it { expect(error.as_json).to be == expected }
  end

  describe '#errors' do
    include_examples 'should have reader', :errors

    context 'when the record errors are empty' do
      let(:attributes) { FactoryBot.attributes_for(:job) }

      it { expect(error.errors).to be == [] }
    end

    context 'when the record has one error' do
      let(:attributes) do
        FactoryBot.attributes_for(:job, company_name: nil)
      end

      it { expect(error.errors).to be == [['company_name', "can't be blank"]] }
    end

    context 'when the record has many errors' do
      let(:attributes) do
        FactoryBot.attributes_for(
          :job,
          company_name: nil,
          source:       '',
          time_period:  'the distant future'
        )
      end
      let(:expected) do
        [
          ['company_name', "can't be blank"],
          ['source',       "can't be blank"],
          ['time_period',  'must be in YYYY-MM format']
        ]
      end

      it { expect(error.errors).to be == expected }
    end
  end

  describe '#message' do
    let(:expected) { "#{record_class} has validation errors" }

    include_examples 'should have reader', :message

    context 'when the record errors are empty' do
      let(:attributes) { FactoryBot.attributes_for(:job) }

      it { expect(error.message).to be == expected }
    end

    context 'when the record has one error' do
      let(:attributes) do
        FactoryBot.attributes_for(:job, company_name: nil)
      end
      let(:expected) { "#{super()}: company_name can't be blank" }

      it { expect(error.message).to be == expected }
    end

    context 'when the record has many errors' do
      let(:attributes) do
        FactoryBot.attributes_for(
          :job,
          company_name: nil,
          source:       '',
          time_period:  'the distant future'
        )
      end
      let(:expected) do
        "#{super()}: company_name can't be blank, source can't be blank," \
        ' time_period must be in YYYY-MM format'
      end

      it { expect(error.message).to be == expected }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  describe '#type' do
    include_examples 'should have reader', :type, 'failed_validation'
  end
end
