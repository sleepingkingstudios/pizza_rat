# frozen_string_literal: true

require 'support/matchers/have_result'

RSpec.describe RSpec::Matchers do # rubocop:disable RSpec/FilePath
  let(:example_group) { self }
  let(:matcher_class) { Cuprum::RSpec::BeAResultMatcher }

  describe '#have_failing_result' do
    let(:matcher) { example_group.have_failing_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:have_failing_result)
        .with(0).arguments
    end

    it { expect(matcher).to be_a RSpec::Matchers::AliasedMatcher }

    it { expect(matcher.base_matcher).to be_a matcher_class }

    it 'should have a custom description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result with status: :failure'
    end
  end

  describe '#have_passing_result' do
    let(:matcher) { example_group.have_passing_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:have_passing_result)
        .with(0).arguments
    end

    it { expect(matcher).to be_a RSpec::Matchers::AliasedMatcher }

    it { expect(matcher.base_matcher).to be_a matcher_class }

    it 'should have a custom description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result with status: :success'
    end
  end

  describe '#have_result' do
    let(:matcher) { example_group.have_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:have_result)
        .with(0).arguments
    end

    it { expect(matcher).to be_a RSpec::Matchers::AliasedMatcher }

    it { expect(matcher.base_matcher).to be_a matcher_class }

    it 'should have a custom description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result'
    end
  end
end
