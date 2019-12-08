# frozen_string_literal: true

require 'errors/invalid_parameters'

RSpec.describe Errors::InvalidParameters do
  subject(:error) { described_class.new(errors: errors) }

  let(:errors) { [['attributes', 'must be a Hash']] }

  describe '::TYPE' do
    include_examples 'should define constant', :TYPE, 'invalid_parameters'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => { 'errors' => errors },
        'message' => error.message,
        'type'    => described_class::TYPE
      }
    end

    it { expect(error).to respond_to(:as_json).with(0).arguments }

    it { expect(error.as_json).to be == expected }
  end

  describe '#errors' do
    include_examples 'should have reader', :errors, -> { errors }
  end

  describe '#message' do
    context 'when the errors are empty' do
      let(:errors)   { [] }
      let(:expected) { 'Invalid request parameters' }

      it { expect(error.message).to be == expected }
    end

    context 'when the errors have one item' do
      let(:errors)   { [['attributes', 'must be a Hash']] }
      let(:expected) { 'Invalid request parameters: attributes must be a Hash' }

      it { expect(error.message).to be == expected }
    end

    context 'when the errors have one item with a nested key' do
      let(:errors)   { [['records.0.attributes', 'must be a Hash']] }
      let(:expected) do
        'Invalid request parameters: records 0 attributes must be a Hash'
      end

      it { expect(error.message).to be == expected }
    end

    context 'when the errors have many items' do
      let(:errors) do
        [
          ['attributes', 'must be a Hash'],
          ['id',         "can't be blank"],
          ['stars',      'must be aligned']
        ]
      end
      let(:expected) do
        "Invalid request parameters: attributes must be a Hash, id can't be" \
        ' blank, stars must be aligned'
      end

      it { expect(error.message).to be == expected }
    end
  end

  describe '#type' do
    include_examples 'should have reader', :type, 'invalid_parameters'
  end
end
