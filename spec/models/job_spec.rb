# frozen_string_literal: true

require 'rails_helper'

require 'support/examples/model_examples'

RSpec.describe Job, type: :model do
  include Spec::Support::Examples::ModelExamples

  shared_context 'when the job has a time period' do
    let(:time_period) { FactoryBot.build(:time_period) }

    before(:example) do
      time_period.save!

      job.time_period = time_period
    end
  end

  subject(:job) { described_class.new(attributes) }

  let(:attributes) do
    {
      action_required:    false,
      application_active: true,
      application_status: 'interviewing',
      company_name:       'Umbrella Corp',
      data:               {
        'events' => [
          { 'type' => 'viewed_listing' },
          { 'type' => 'application_sent' },
          { 'type' => 'interview_scheduled' }
        ]
      },
      notes:              'BYO-Biohazard Suit',
      source:             'PlayStation',
      source_data:        { 'publisher' => 'Capcom' },
      title:              'Test Subject'
    }
  end

  describe '::ApplicationStatuses' do
    let(:expected_statuses) do
      {
        APPLIED:      'applied',
        CLOSED:       'closed',
        INTERVIEWING: 'interviewing',
        PROSPECT:     'prospect'
      }
    end

    include_examples 'should define immutable constant', :ApplicationStatuses

    it 'should enumerate the statuses' do
      expect(described_class::ApplicationStatuses.all)
        .to be == expected_statuses
    end

    describe '::APPLIED' do
      it 'should store the value' do
        expect(described_class::ApplicationStatuses::APPLIED).to be == 'applied'
      end
    end

    describe '::CLOSED' do
      it 'should store the value' do
        expect(described_class::ApplicationStatuses::CLOSED).to be == 'closed'
      end
    end

    describe '::INTERVIEWING' do
      it 'should store the value' do
        expect(described_class::ApplicationStatuses::INTERVIEWING)
          .to be == 'interviewing'
      end
    end

    describe '::PROSPECT' do
      it 'should store the value' do
        expect(described_class::ApplicationStatuses::PROSPECT)
          .to be == 'prospect'
      end
    end
  end

  describe '::Factory' do
    include_examples 'should define constant',
      :Factory,
      -> { be_a Operations::Records::Factory }

    it { expect(described_class::Factory.record_class).to be described_class }
  end

  describe '.applied' do
    it { expect(described_class).to respond_to(:applied).with(0).arguments }

    it { expect(described_class.applied).to be_a ActiveRecord::Relation }

    it { expect(described_class.applied).to be == [] }

    context 'when there are many jobs' do
      let(:expected) do
        Array.new(3) { FactoryBot.build(:job, :applied, :with_time_period) }
      end

      before(:example) do
        expected.each(&:save!)

        FactoryBot.create(:job, :closed,       :with_time_period)
        FactoryBot.create(:job, :interviewing, :with_time_period)
        FactoryBot.create(:job, :prospect,     :with_time_period)
      end

      it { expect(described_class.applied).to contain_exactly(*expected) }
    end
  end

  describe '.closed' do
    it { expect(described_class).to respond_to(:closed).with(0).arguments }

    it { expect(described_class.closed).to be_a ActiveRecord::Relation }

    it { expect(described_class.closed).to be == [] }

    context 'when there are many jobs' do
      let(:expected) do
        Array.new(3) { FactoryBot.build(:job, :closed, :with_time_period) }
      end

      before(:example) do
        expected.each(&:save!)

        FactoryBot.create(:job, :applied,      :with_time_period)
        FactoryBot.create(:job, :interviewing, :with_time_period)
        FactoryBot.create(:job, :prospect,     :with_time_period)
      end

      it { expect(described_class.closed).to contain_exactly(*expected) }
    end
  end

  describe '.interviewing' do
    it 'should define the scope' do
      expect(described_class).to respond_to(:interviewing).with(0).arguments
    end

    it { expect(described_class.interviewing).to be_a ActiveRecord::Relation }

    it { expect(described_class.interviewing).to be == [] }

    context 'when there are many jobs' do
      let(:expected) do
        Array.new(3) do
          FactoryBot.build(:job, :interviewing, :with_time_period)
        end
      end

      before(:example) do
        expected.each(&:save!)

        FactoryBot.create(:job, :applied,  :with_time_period)
        FactoryBot.create(:job, :closed,   :with_time_period)
        FactoryBot.create(:job, :prospect, :with_time_period)
      end

      it { expect(described_class.interviewing).to contain_exactly(*expected) }
    end
  end

  describe '.prospects' do
    it { expect(described_class).to respond_to(:prospects).with(0).arguments }

    it { expect(described_class.prospects).to be_a ActiveRecord::Relation }

    it { expect(described_class.prospects).to be == [] }

    context 'when there are many jobs' do
      let(:expected) do
        Array.new(3) { FactoryBot.build(:job, :prospect, :with_time_period) }
      end

      before(:example) do
        expected.each(&:save!)

        FactoryBot.create(:job, :applied,      :with_time_period)
        FactoryBot.create(:job, :closed,       :with_time_period)
        FactoryBot.create(:job, :interviewing, :with_time_period)
      end

      it { expect(described_class.prospects).to contain_exactly(*expected) }
    end
  end

  describe '#action_required' do
    include_examples 'should have attribute', :action_required, default: true
  end

  describe '#action_required?' do
    include_examples 'should define predicate', :action_required?

    context 'when the job does not require action' do
      let(:attributes) { super().merge(action_required: false) }

      it { expect(job.action_required?).to be false }
    end

    context 'when the job requires action' do
      let(:attributes) { super().merge(action_required: true) }

      it { expect(job.action_required?).to be true }
    end
  end

  describe '#application_active' do
    include_examples 'should have attribute', :application_active, default: true
  end

  describe '#application_active?' do
    include_examples 'should define predicate', :application_active?

    context 'when the job application is inactive' do
      let(:attributes) { super().merge(application_active: false) }

      it { expect(job.application_active?).to be false }
    end

    context 'when the job application is active' do
      let(:attributes) { super().merge(application_active: true) }

      it { expect(job.application_active?).to be true }
    end
  end

  describe '#application_status' do
    include_examples 'should have attribute',
      :application_status,
      default: described_class::ApplicationStatuses::PROSPECT
  end

  describe '#company_name' do
    include_examples 'should have attribute', :company_name, default: ''
  end

  describe '#created_at' do
    include_examples 'should have reader', :created_at
  end

  describe '#data' do
    include_examples 'should have attribute', :data, default: {}
  end

  describe '#id' do
    include_context 'when the job has a time period'

    include_examples 'should have attribute',
      :id,
      value: 0

    context 'when the job is persisted' do
      before(:example) { job.save! }

      it { expect(job.id).to be_a Integer }
    end
  end

  describe '#notes' do
    include_examples 'should have attribute', :notes, default: ''
  end

  describe '#source' do
    include_examples 'should have attribute', :source
  end

  describe '#source_data' do
    include_examples 'should have attribute', :source_data, default: {}
  end

  describe '#time_period' do
    include_examples 'should have property', :time_period

    wrap_context 'when the job has a time period' do
      it { expect(job.time_period).to be == time_period }
    end
  end

  describe '#time_period_id' do
    include_examples 'should have attribute',
      :time_period_id,
      value: nil

    wrap_context 'when the job has a time period' do
      it { expect(job.time_period_id).to be == time_period.id }
    end
  end

  describe '#title' do
    include_examples 'should have attribute', :title, default: ''
  end

  describe '#updated_at' do
    include_examples 'should have reader', :created_at
  end

  describe '#valid?' do
    wrap_context 'when the job has a time period' do
      it { expect(job).not_to have_errors }
    end

    include_examples 'should validate the presence of',
      :application_status,
      type: String

    include_examples 'should validate the inclusion of',
      :application_status,
      in: described_class::ApplicationStatuses.all.values

    include_examples 'should validate the presence of',
      :company_name,
      type: String

    include_examples 'should validate the presence of',
      :source,
      type: String

    include_examples 'should validate the presence of',
      :time_period,
      message: 'must exist'
  end
end
