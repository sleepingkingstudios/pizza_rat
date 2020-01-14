# frozen_string_literal: true

require 'rails_helper'

require 'support/examples/model_examples'

RSpec.describe TimePeriod, type: :model do
  include Spec::Support::Examples::ModelExamples

  shared_context 'when there are many time periods' do
    let(:time_period_attributes) do
      [
        { year: 1977, month: 5 },
        { year: 1980, month: 6 },
        { year: 1983, month: 5 }
      ]
    end
    let(:time_periods) do
      time_period_attributes.map { |hsh| described_class.new(hsh) }
    end

    before(:example) do
      time_periods.each(&:save!)
    end
  end

  subject(:time_period) { described_class.new(attributes) }

  let(:attributes) do
    {
      month: 5,
      year:  1977
    }
  end

  describe '::Factory' do
    include_examples 'should define constant',
      :Factory,
      -> { be_a Operations::Records::Factory }

    it { expect(described_class::Factory.record_class).to be described_class }
  end

  describe '.active' do
    it { expect(described_class).to respond_to(:active).with(0).arguments }

    it { expect(described_class.active).to be nil }

    wrap_context 'when there are many time periods' do
      let(:expected) do
        time_periods.find { |time_period| time_period.year == 1983 }
      end

      it { expect(described_class.active).to be == expected }
    end
  end

  describe '#created_at' do
    include_examples 'should have reader', :created_at
  end

  describe '#id' do
    include_examples 'should have attribute',
      :id,
      value: 0

    context 'when the time period is persisted' do
      before(:example) { time_period.save! }

      it { expect(time_period.id).to be_a Integer }
    end
  end

  describe '#jobs' do
    include_examples 'should have property', :jobs, []

    context 'when there are many jobs' do
      let(:jobs) do
        Array.new(3) { FactoryBot.build(:job, time_period: time_period) }
      end

      before(:example) do
        jobs.each(&:save!)

        3.times { FactoryBot.create(:job, :with_time_period) }
      end

      it { expect(time_period.jobs).to contain_exactly(*jobs) }
    end
  end

  describe '#month' do
    include_examples 'should have attribute', :month
  end

  describe '#updated_at' do
    include_examples 'should have reader', :updated_at
  end

  describe '#valid?' do
    it { expect(time_period).not_to have_errors }

    include_examples 'should validate the presence of',
      :month,
      type: Integer

    include_examples 'should validate the numericality of',
      :month,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    12,
      only_integer:             true

    include_examples 'should validate the scoped uniqueness of',
      :month,
      scope: { year: [1977, 1980, 1983] }

    include_examples 'should validate the presence of',
      :year,
      type: Integer

    include_examples 'should validate the numericality of',
      :year,
      greater_than_or_equal_to: 1,
      only_integer:             true
  end

  describe '#year' do
    include_examples 'should have attribute', :year
  end
end
