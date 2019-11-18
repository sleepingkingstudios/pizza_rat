# frozen_string_literal: true

require 'fixtures/mappings/property_mapping'

RSpec.describe Fixtures::Mappings::PropertyMapping do
  shared_context 'with a subclass with defined mapping' do
    let(:described_class) { Spec::UpcaseMapping }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::UpcaseMapping', Fixtures::Mappings::PropertyMapping \
    do |klass|
      klass.define_method(:map_property) do |value:, **_kwargs|
        value.upcase
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:mapping) { described_class.new(property: property) }

  let(:property) { 'name' }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:property)
    end
  end

  describe '#call' do
    it { expect(mapping).to respond_to(:call).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { mapping.call nil }
          .to raise_error ArgumentError, 'data must be a Hash'
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { mapping.call Object.new }
          .to raise_error ArgumentError, 'data must be a Hash'
      end
    end

    describe 'with an empty Hash' do
      it { expect(mapping.call({})).to be == {} }
    end

    describe 'with a Hash with the property' do
      let(:data) do
        {
          'name'        => 'Widget',
          'description' => 'A simple widget.'
        }
      end

      it { expect(mapping.call(data)).to be == data }
    end

    wrap_context 'with a subclass with defined mapping' do
      describe 'with an empty Hash' do
        it { expect(mapping.call({})).to be == {} }
      end

      describe 'with a Hash with the property' do
        let(:data) do
          {
            'name'        => 'Widget',
            'description' => 'A simple widget.'
          }
        end
        let(:expected) do
          data.merge('name' => data['name'].upcase)
        end

        it { expect(mapping.call(data)).to be == expected }
      end
    end
  end

  describe '#property' do
    include_examples 'should define reader', :property, -> { property }

    context 'when the property is a symbol' do
      let(:property) { :name }

      it { expect(mapping.property).to be == property.to_s }
    end
  end
end
