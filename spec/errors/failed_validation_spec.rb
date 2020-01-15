# frozen_string_literal: true

require 'rails_helper'

require 'errors/failed_validation'

RSpec.describe Errors::FailedValidation do
  subject(:error) { described_class.new(record: record) }

  let(:attributes) do
    FactoryBot.attributes_for(:manufacturer, name: nil)
  end
  let(:record_class) { Spec::Manufacturer }
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
          'errors'       => [['name', "can't be blank"]],
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
      let(:attributes) { FactoryBot.attributes_for(:manufacturer) }

      it { expect(error.errors).to be == [] }
    end

    context 'when the record has one error' do
      let(:attributes) do
        FactoryBot.attributes_for(:manufacturer, name: nil)
      end

      it { expect(error.errors).to be == [['name', "can't be blank"]] }
    end

    context 'when the record has many errors' do
      let(:attributes) do
        FactoryBot.attributes_for(
          :manufacturer,
          founded_at: nil,
          name:       nil
        )
      end
      let(:expected) do
        [
          ['founded_at', "can't be blank"],
          ['name',       "can't be blank"]
        ]
      end

      it { expect(error.errors).to be == expected }
    end
  end

  describe '#message' do
    let(:expected) { "#{record_class} has validation errors" }

    include_examples 'should have reader', :message

    context 'when the record errors are empty' do
      let(:attributes) { FactoryBot.attributes_for(:manufacturer) }

      it { expect(error.message).to be == expected }
    end

    context 'when the record has one error' do
      let(:attributes) do
        FactoryBot.attributes_for(:manufacturer, name: nil)
      end
      let(:expected) { "#{super()}: name can't be blank" }

      it { expect(error.message).to be == expected }
    end

    context 'when the record has many errors' do
      let(:attributes) do
        FactoryBot.attributes_for(
          :manufacturer,
          founded_at: nil,
          name:       nil
        )
      end
      let(:expected) do
        "#{super()}: founded_at can't be blank, name can't be blank"
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
