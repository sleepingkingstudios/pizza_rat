# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module OperationFactoryExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should define operation' do |method_name, parent_class|
      constant_name = method_name.to_s.camelize

      describe "::#{constant_name}" do
        let(:operation_class) { factory.const_get(constant_name) }
        let(:operation)       { operation_class.new }

        it { expect(factory).to define_constant(constant_name) }

        it { expect(operation_class).to be_a Class }

        it { expect(operation_class).to be <= parent_class }

        it { expect(operation_class).to be_constructible.with(0).arguments }

        it { expect(operation.record_class).to be record_class }
      end

      describe "##{method_name}" do
        let(:operation) { factory.public_send(method_name) }

        it { expect(factory).to respond_to(method_name).with(0).arguments }

        it { expect(operation).to be_a parent_class }

        it { expect(operation.record_class).to be record_class }
      end
    end
  end
end
