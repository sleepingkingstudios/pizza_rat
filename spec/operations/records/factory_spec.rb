# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/factory'

require 'support/examples/operation_factory_examples'

RSpec.describe Operations::Records::Factory do
  include Spec::Support::Examples::OperationFactoryExamples

  subject(:factory) { described_class.new(record_class) }

  let(:record_class) { Job }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::for' do
    it { expect(described_class).to respond_to(:for).with(1).argument }

    describe 'with the name of a record class that does not define a factory' do
      let(:record_class) { ApplicationRecord }

      it 'should return an instance of the base factory class' do
        expect(described_class.for record_class.name).to be_a described_class
      end

      it 'should set the record class' do
        expect(described_class.for(record_class.name).record_class)
          .to be record_class
      end
    end

    describe 'with the name of a record class that defines a factory' do
      let(:record_class) { Job }

      it 'should return the factory class for the record class' do
        expect(described_class.for record_class.name)
          .to be record_class::Factory
      end
    end

    describe 'with a record class that does not define a factory' do
      let(:record_class) { ApplicationRecord }

      it 'should return an instance of the base factory class' do
        expect(described_class.for record_class).to be_a described_class
      end

      it 'should set the record class' do
        expect(described_class.for(record_class).record_class)
          .to be record_class
      end
    end

    describe 'with a record class that defines a factory' do
      let(:record_class) { Job }

      it 'should return the factory class for the record class' do
        expect(described_class.for record_class).to be record_class::Factory
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end

  include_examples 'should define operation',
    :assign,
    Operations::Records::Assign

  include_examples 'should define operation',
    :build,
    Operations::Records::Build

  include_examples 'should define operation',
    :create,
    Operations::Records::Create

  include_examples 'should define operation',
    :destroy,
    Operations::Records::Destroy

  include_examples 'should define operation',
    :find_many,
    Operations::Records::FindMany

  include_examples 'should define operation',
    :find_matching,
    Operations::Records::FindMatching

  include_examples 'should define operation',
    :find_one,
    Operations::Records::FindOne

  include_examples 'should define operation',
    :save,
    Operations::Records::Save

  include_examples 'should define operation',
    :update,
    Operations::Records::Update
end
