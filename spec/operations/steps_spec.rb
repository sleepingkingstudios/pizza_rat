# frozen_string_literal: true

require 'operations/steps'

require 'support/examples/operation_steps_examples'

RSpec.describe Operations::Steps do
  include Spec::Support::Examples::OperationStepsExamples

  subject(:operation) { described_class.new }

  let(:described_class) { Spec::Operation }

  example_class 'Spec::Operation', Cuprum::Operation do |klass|
    klass.include Operations::Steps # rubocop:disable RSpec/DescribedClass

    klass.define_method(:do_something) { |*_args| }
  end

  describe '#call' do
    let(:implementation) { -> {} }
    let(:result)         { run_steps.to_cuprum_result }

    before(:example) do
      described_class.define_method(:process, &implementation)
    end

    def run_steps
      operation.call
    end

    include_examples 'should execute the steps'
  end

  include_examples 'should implement the Steps methods'
end
