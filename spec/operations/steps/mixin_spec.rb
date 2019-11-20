# frozen_string_literal: true

require 'operations/steps'

require 'support/examples/operation_steps_examples'

RSpec.describe Operations::Steps::Mixin do
  include Spec::Support::Examples::OperationStepsExamples

  subject(:object) { described_class.new }

  let(:described_class) { Spec::Processing }

  example_class 'Spec::Processing' do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.include Operations::Steps::Mixin
    # rubocop:enable RSpec/DescribedClass

    klass.define_method(:do_something) { |*_args| }
  end

  include_examples 'should implement the Steps methods'
end
