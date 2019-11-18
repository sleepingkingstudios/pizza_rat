# frozen_string_literal: true

require 'rails_helper'

require 'fixtures'

require 'support/examples/rake_examples'

RSpec.describe 'rake' do # rubocop:disable RSpec/DescribeClass
  include Spec::Support::Examples::RakeExamples

  before(:context) do # rubocop:disable RSpec/BeforeAfterAll
    Spec::Support::Examples::RakeExamples.load_tasks_once
  end

  describe 'data:load' do
    let(:directory) { 'secrets' }
    let(:task)      { Rake::Task['data:load'].tap(&:reenable) }

    before(:example) { allow(Fixtures).to receive(:create) }

    include_examples 'should list the task',
      'data:load',
      'Loads the data from the specified fixture directory into the database',
      arguments: %w[directory]

    describe 'with no arguments' do
      it 'should raise an error' do
        expect { task.invoke }
          .to raise_error ArgumentError, "directory can't be blank"
      end
    end

    context 'when the data does not exist' do
      before(:example) do
        allow(Fixtures).to receive(:exist?).and_return(false)
      end

      it 'should not load the data' do
        task.invoke(directory)

        expect(Fixtures).not_to have_received(:create)
      end
    end

    context 'when all of the data exists' do
      let(:record_classes) { [Job] }

      before(:example) do
        allow(Fixtures).to receive(:exist?).and_return(true)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should load the existing data from /data/secrets' do
        task.invoke(directory)

        record_classes.each do |record_class|
          expect(Fixtures)
            .to have_received(:create)
            .with(record_class, environment: directory)
            .ordered
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'data:load:fixtures' do
    let(:task) { Rake::Task['data:load:fixtures'].tap(&:reenable) }

    before(:example) { allow(Fixtures).to receive(:create) }

    include_examples 'should list the task',
      'data:load:fixtures',
      'Loads the data from /data/fixtures into the database'

    context 'when the data does not exist' do
      before(:example) do
        allow(Fixtures).to receive(:exist?).and_return(false)
      end

      it 'should not load the data' do
        task.invoke

        expect(Fixtures).not_to have_received(:create)
      end
    end

    context 'when all of the data exists' do
      let(:record_classes) { [Job] }

      before(:example) do
        allow(Fixtures).to receive(:exist?).and_return(true)
      end

      it 'should load the existing data from /data/fixtures' do
        task.invoke

        record_classes.each do |record_class|
          expect(Fixtures).to have_received(:create).with(record_class).ordered
        end
      end
    end
  end
end
