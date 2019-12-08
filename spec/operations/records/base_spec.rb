# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/base'

RSpec.describe Operations::Records::Base do
  subject(:operation) { described_class.new(record_class) }

  let(:record_class) { Job }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '::subclass' do
    let(:subclass)  { described_class.subclass(record_class) }
    let(:operation) { subclass.new }
    let(:expected)  { "Operations::Records::Base#{record_class}" }

    it { expect(described_class).to respond_to(:subclass).with(1).argument }

    it { expect(subclass).to be_a Class }

    it { expect(subclass).to be < described_class }

    it { expect(subclass).to be_constructible.with(0).arguments }

    it { expect(subclass.name).to be == expected }

    it { expect(operation.record_class).to be record_class }

    context 'when the parent class has constructor arguments' do
      let(:described_class) { Spec::CustomOperation }
      let(:arguments)       { %w[ichi ni san] }
      let(:keywords)        { { yon: 4, go: 5, roku: 6 } }
      let(:operation)       { subclass.new(*arguments, **keywords) }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::CustomOperation', Operations::Records::Base \
      do |klass|
        klass.define_method(:initialize) do |record_class, *args, **kwargs|
          super(record_class)

          @arguments = args
          @keywords  = kwargs
        end

        klass.send(:attr_reader, :arguments)
        klass.send(:attr_reader, :keywords)
      end
      # rubocop:enable RSpec/DescribedClass

      it { expect(subclass).to be_a Class }

      it { expect(subclass).to be < described_class }

      it 'should define the constructor' do
        expect(subclass)
          .to be_constructible
          .with(1).argument
          .and_unlimited_arguments
      end

      it { expect(operation.record_class).to be record_class }

      it { expect(operation.arguments).to be == arguments }

      it { expect(operation.keywords).to be == keywords }
    end

    context 'when the parent class has a custom name' do
      let(:described_class) { Spec::RandomizeOperation }
      let(:expected)        { "Spec::Randomize#{record_class}" }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::RandomizeOperation', Operations::Records::Base
      # rubocop:enable RSpec/DescribedClass

      it { expect(subclass.name).to be == expected }
    end
  end

  describe '#call' do
    it { expect(operation).to respond_to(:call) }

    it 'should return a failing result' do
      expect(operation.call).to be_a_failing_result
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
