# frozen_string_literal: true

require 'support/matchers/call_command_step'

RSpec.describe RSpec::Matchers do # rubocop:disable RSpec/FilePath
  let(:example_group) { self }

  describe '#call_command_step' do
    let(:matcher) { example_group.call_command_step(Object.new, :foo) }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:call_command_step)
        .with(1..2).arguments
    end

    it 'should return a matcher' do
      expect(matcher).to be_a Spec::Support::Matchers::CallCommandStepMatcher
    end

    it { expect(matcher.description).to be == 'call command step :foo' }
  end
end
