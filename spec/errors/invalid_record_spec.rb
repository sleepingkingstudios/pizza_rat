# frozen_string_literal: true

require 'rails_helper'

require 'errors/invalid_record'

RSpec.describe Errors::InvalidRecord do
  subject(:error) { described_class.new(record_class: record_class) }

  let(:record_class) { Job }

  describe '::TYPE' do
    include_examples 'should define constant', :TYPE, 'invalid_record'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:record_class)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'record_class' => record_class.name
        },
        'message' => error.message,
        'type'    => described_class::TYPE
      }
    end

    it { expect(error).to respond_to(:as_json).with(0).arguments }

    it { expect(error.as_json).to be == expected }
  end

  describe '#message' do
    include_examples 'should have reader',
      :message,
      -> { "Record should be a #{record_class.name}" }
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  describe '#type' do
    include_examples 'should have reader', :type, 'invalid_record'
  end
end
