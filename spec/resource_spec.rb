# frozen_string_literal: true

require 'rails_helper'

require 'resource'

RSpec.describe Resource do
  shared_context 'when the name is specified' do
    let(:options)       { super().merge(name: 'gadget') }
    let(:expected_name) { 'gadget' }
  end

  shared_context 'with a record class with qualified name' do
    let(:record_class)  { Spec::Widget }
    let(:expected_name) { 'widget' }

    example_class 'Spec::Widget', Struct.new(:id)
  end

  subject(:resource) { described_class.new(record_class, **options) }

  let(:record_class) { Spec::Manufacturer }
  let(:options)      { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:name, :plural_name, :singular_name)
    end

    describe 'with name: an object' do
      let(:error_message) { 'name must be a String or Symbol' }

      it 'should raise an error' do
        expect { described_class.new(record_class, name: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with plural_name: an object' do
      let(:error_message) { 'name must be a String or Symbol' }

      it 'should raise an error' do
        expect do
          described_class.new(record_class, plural_name: Object.new.freeze)
        end
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with singular_name: an object' do
      let(:error_message) { 'name must be a String or Symbol' }

      it 'should raise an error' do
        expect do
          described_class.new(record_class, singular_name: Object.new.freeze)
        end
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with record_class: nil' do
      let(:error_message) { 'must provide a record class or a name' }

      it 'should raise an error' do
        expect { described_class.new(nil) }
          .to raise_error ArgumentError, error_message
      end

      describe 'with name: nil' do
        it 'should raise an error' do
          expect { described_class.new(nil, name: nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: an empty string' do
        it 'should raise an error' do
          expect { described_class.new(nil, name: '') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: a string' do
        let(:resource) { described_class.new(nil, name: 'gadget') }

        it { expect(resource).to be_a described_class }

        it { expect(resource.name).to be == 'gadget' }

        it { expect(resource.record_class).to be nil }
      end
    end
  end

  describe '#index_path' do
    it 'should define the method' do
      expect(resource)
        .to respond_to(:index_path)
        .with(0).arguments
        .and_any_keywords
    end

    it { expect(resource.index_path).to be == '/manufacturers' }

    wrap_context 'when the name is specified' do
      it { expect(resource.index_path).to be == "/#{expected_name.pluralize}" }
    end

    wrap_context 'with a record class with qualified name' do
      it { expect(resource.index_path).to be == "/#{expected_name.pluralize}" }
    end
  end

  describe '#operation_factory' do
    include_examples 'should define reader', :operation_factory

    context 'when the record class does not define a factory' do
      let(:record_class) { Spec::Role }

      example_class 'Spec::Role', ApplicationRecord do |klass|
        klass.table_name = 'manufacturers'
      end

      it 'should return a factory' do
        expect(resource.operation_factory).to be_a Operations::Records::Factory
      end

      it { expect(resource.operation_factory.record_class).to be record_class }
    end

    context 'when the record class defines a factory' do
      it 'should return a factory' do
        expect(resource.operation_factory).to be_a Operations::Records::Factory
      end

      it { expect(resource.operation_factory.record_class).to be record_class }
    end

    context 'with a nil record class' do
      let(:record_class) { nil }
      let(:options)      { super().merge(name: 'resource') }
      let(:error_message) do
        'record class must be a non-abstract ActiveRecord class'
      end

      it 'should raise an error' do
        expect { resource.operation_factory }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#name' do
    include_examples 'should have reader', :name, 'manufacturer'

    wrap_context 'when the name is specified' do
      it { expect(resource.name).to be == expected_name }

      context 'when the name is nil' do
        let(:options) { super().merge(name: nil) }

        it { expect(resource.name).to be == 'manufacturer' }
      end

      context 'when the name is an empty string' do
        let(:options) { super().merge(name: '') }

        it { expect(resource.name).to be == 'manufacturer' }
      end

      context 'when the name is a capitalized string' do
        let(:options) { super().merge(name: expected_name.capitalize) }

        it { expect(resource.name).to be == expected_name }
      end

      context 'when the name is a symbol' do
        let(:options) { super().merge(name: expected_name.intern) }

        it { expect(resource.name).to be == expected_name }
      end
    end

    wrap_context 'with a record class with qualified name' do
      it { expect(resource.name).to be == expected_name }
    end
  end

  describe '#plural_name' do
    include_examples 'should have reader', :plural_name, 'manufacturers'

    wrap_context 'when the name is specified' do
      it { expect(resource.plural_name).to be == expected_name.pluralize }

      context 'when the name is a plural string' do
        let(:options) { super().merge(name: expected_name.pluralize) }

        it { expect(resource.plural_name).to be == expected_name.pluralize }
      end
    end

    context 'when the plural name is specified' do
      let(:options) { super().merge(plural_name: 'gadgets') }

      it { expect(resource.plural_name).to be == 'gadgets' }

      context 'when the plural name is nil' do
        let(:options) { super().merge(plural_name: nil) }

        it { expect(resource.plural_name).to be == 'manufacturers' }
      end

      context 'when the plural name is a capitalized string' do
        let(:options) { super().merge(plural_name: 'Gadgets') }

        it { expect(resource.plural_name).to be == 'gadgets' }
      end

      context 'when the plural name is a singular string' do
        let(:options) { super().merge(plural_name: 'gadget') }

        it { expect(resource.plural_name).to be == 'gadget' }
      end

      context 'when the plural name is an ambiguously plural string' do
        let(:options) { super().merge(plural_name: 'metadata') }

        it { expect(resource.plural_name).to be == 'metadata' }
      end

      context 'when the plural name is a symbol' do
        let(:options) { super().merge(name: :gadgets) }

        it { expect(resource.plural_name).to be == 'gadgets' }
      end
    end

    wrap_context 'with a record class with qualified name' do
      it { expect(resource.plural_name).to be == expected_name.pluralize }
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  describe '#show_path' do
    let(:record) { FactoryBot.create(:manufacturer) }

    it 'should define the method' do
      expect(resource)
        .to respond_to(:show_path)
        .with(1).argument
        .and_any_keywords
    end

    it 'should return the show path' do
      expect(resource.show_path(record)).to be == "/manufacturers/#{record.id}"
    end

    wrap_context 'when the name is specified' do
      it 'should return the show path' do
        expect(resource.show_path(record))
          .to be == "/#{expected_name.pluralize}/#{record.id}"
      end
    end

    wrap_context 'with a record class with qualified name' do
      let(:record) { record_class.new(1) }

      it 'should return the show path' do
        expect(resource.show_path(record))
          .to be == "/#{expected_name.pluralize}/#{record.id}"
      end
    end
  end

  describe '#singular_name' do
    include_examples 'should have reader', :singular_name, 'manufacturer'

    wrap_context 'when the name is specified' do
      it { expect(resource.singular_name).to be == expected_name.singularize }

      context 'when the name is a plural string' do
        let(:options) { super().merge(name: expected_name.pluralize) }

        it { expect(resource.singular_name).to be == expected_name.singularize }
      end
    end

    context 'when the singular name is specified' do
      let(:options) { super().merge(singular_name: 'gadget') }

      it { expect(resource.singular_name).to be == 'gadget' }

      context 'when the singular name is nil' do
        let(:options) { super().merge(singular_name: nil) }

        it { expect(resource.singular_name).to be == 'manufacturer' }
      end

      context 'when the singular name is a capitalized string' do
        let(:options) { super().merge(singular_name: 'Gadget') }

        it { expect(resource.singular_name).to be == 'gadget' }
      end

      context 'when the singular name is a plural string' do
        let(:options) { super().merge(singular_name: 'gadgets') }

        it { expect(resource.singular_name).to be == 'gadgets' }
      end

      context 'when the singular name is an ambiguously plural string' do
        let(:options) { super().merge(singular_name: 'metadata') }

        it { expect(resource.singular_name).to be == 'metadata' }
      end

      context 'when the singular name is a symbol' do
        let(:options) { super().merge(name: :gadget) }

        it { expect(resource.singular_name).to be == 'gadget' }
      end
    end
  end
end
