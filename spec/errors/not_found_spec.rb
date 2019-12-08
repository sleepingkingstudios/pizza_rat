# frozen_string_literal: true

require 'rails_helper'

require 'errors/not_found'

RSpec.describe Errors::NotFound do
  subject(:error) do
    described_class.new(
      attributes:   attributes,
      record_class: record_class
    )
  end

  let(:attributes)   { { id: '00000000-0000-0000-0000-000000000000' } }
  let(:record_class) { Job }

  describe '::TYPE' do
    include_examples 'should define constant', :TYPE, 'not_found'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:attributes, :record_class)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'attributes'   => attributes.stringify_keys,
          'record_class' => record_class.name
        },
        'message' => error.message,
        'type'    => described_class::TYPE
      }
    end

    it { expect(error).to respond_to(:as_json).with(0).arguments }

    it { expect(error.as_json).to be == expected }
  end

  describe '#attributes' do
    include_examples 'should have reader', :attributes, -> { attributes }
  end

  describe '#message' do
    let(:expected) { "#{record_class.name} not found" }

    context 'when the attributes are empty' do
      let(:attributes) { {} }

      it { expect(error.message).to be == expected }
    end

    context 'when the attributes have one item' do
      let(:attributes) { { id: '00000000-0000-0000-0000-000000000000' } }
      let(:expected) do
        %(#{super()} with attributes id: "00000000-0000-0000-0000-000000000000")
      end

      it { expect(error.message).to be == expected }
    end

    context 'when the errors have many items' do
      let(:attributes) do
        {
          level:  10,
          name:   'Invoked Apocalypse',
          school: 'Devastation'
        }
      end
      let(:expected) do
        %(#{super()} with attributes level: 10, name: "Invoked Apocalypse",) \
        ' school: "Devastation"'
      end

      it { expect(error.message).to be == expected }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  describe '#type' do
    include_examples 'should have reader', :type, 'not_found'
  end
end
