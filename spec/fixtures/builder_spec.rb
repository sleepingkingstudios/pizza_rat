# frozen_string_literal: true

require 'rails_helper'

require 'fixtures/builder'
require 'fixtures/mappings/property_mapping'

RSpec.describe Fixtures::Builder do
  shared_context 'with a custom environment' do
    subject(:builder) do
      described_class.new(record_class, environment: environment)
    end

    let(:environment) { 'secrets' }
  end

  shared_context 'when data is defined for the resource' do
    let(:data) do
      [
        {
          'id'         => '0',
          'name'       => 'Umbrella Corp',
          'founded_at' => '1996-03-02'
        },
        {
          'id'         => '1',
          'name'       => 'Weyland-Yutani',
          'founded_at' => '1979-06-22'
        },
        {
          'id'         => '2',
          'name'       => 'Raccoon City PD',
          'founded_at' => '1988-1-21'
        }
      ]
    end
  end

  shared_context 'when options are defined for the resource' do
    let(:options) do
      {
        'mappings' => [
          {
            'options' => { 'property' => 'name' },
            'type'    => 'upcase'
          }
        ]
      }
    end

    example_class 'Fixtures::Mappings::Upcase',
      Fixtures::Mappings::PropertyMapping \
      do |klass|
        klass.define_method(:map_property) do |value:, **_kwargs|
          value.upcase
        end
      end
  end

  subject(:builder) { described_class.new(record_class) }

  let(:record_class) { Spec::Manufacturer }
  let(:environment)  { 'fixtures' }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:environment)
    end
  end

  describe '#build' do
    let(:read_data) { [] }

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(builder).to receive(:read).and_return(read_data)
      # rubocop:enable RSpec/SubjectStub
    end

    it 'should define the method' do
      expect(builder)
        .to respond_to(:build)
        .with(0).arguments
        .and_any_keywords
    end

    it 'should delegate to read' do
      builder.build

      # rubocop:disable RSpec/SubjectStub
      expect(builder).to have_received(:read).with({})
      # rubocop:enable RSpec/SubjectStub
    end

    describe 'with count: value' do
      it 'should delegate to read' do
        builder.build(count: 3)

        # rubocop:disable RSpec/SubjectStub
        expect(builder).to have_received(:read).with(count: 3)
        # rubocop:enable RSpec/SubjectStub
      end
    end

    describe 'with except: array' do
      it 'should delegate to read' do
        builder.build(except: %w[description])

        expect(builder) # rubocop:disable RSpec/SubjectStub
          .to have_received(:read)
          .with(except: %w[description])
      end
    end

    context 'when the data has no items' do
      it { expect(builder.build).to be == [] }

      it { expect { builder.build }.not_to change(record_class, :count) }
    end

    context 'when the data has one item' do
      include_context 'when data is defined for the resource'

      let(:read_data) { data[0..0] }
      let(:expected)  { read_data.map { |hsh| record_class.new(hsh) } }

      it { expect(builder.build).to be == expected }

      it { expect { builder.build }.not_to change(record_class, :count) }
    end

    context 'when the data has many items' do
      include_context 'when data is defined for the resource'

      let(:read_data) { data }
      let(:expected)  { read_data.map { |hsh| record_class.new(hsh) } }

      it { expect(builder.build).to be == expected }

      it { expect { builder.build }.not_to change(record_class, :count) }
    end
  end

  describe '#create' do
    let(:read_data) { [] }

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(builder).to receive(:read).and_return(read_data)
      # rubocop:enable RSpec/SubjectStub
    end

    def match_attributes(attributes)
      satisfy do |actual|
        attributes.all? do |key, value|
          matches_attribute?(key, value, actual.public_send(key))
        end
      end
    end

    def matches_attribute?(key, expected, actual)
      if key == 'id' || key.end_with?('_id')
        expected = expected.to_i
      elsif key.end_with?('_at') || key.end_with?('_date')
        expected = Date.parse(expected)
      end

      expected == actual
    end

    it 'should define the method' do
      expect(builder)
        .to respond_to(:create)
        .with(0).arguments
        .and_any_keywords
    end

    it 'should delegate to read' do
      builder.create

      # rubocop:disable RSpec/SubjectStub
      expect(builder).to have_received(:read).with({})
      # rubocop:enable RSpec/SubjectStub
    end

    describe 'with count: value' do
      it 'should delegate to read' do
        builder.create(count: 3)

        # rubocop:disable RSpec/SubjectStub
        expect(builder).to have_received(:read).with(count: 3)
        # rubocop:enable RSpec/SubjectStub
      end
    end

    describe 'with except: array' do
      it 'should delegate to read' do
        builder.create(except: %w[description])

        expect(builder) # rubocop:disable RSpec/SubjectStub
          .to have_received(:read)
          .with(except: %w[description])
      end
    end

    context 'when the data has no items' do
      it { expect(builder.create).to be == [] }
    end

    context 'when the data has one item' do
      include_context 'when data is defined for the resource'

      let(:read_data) { data[0..0] }
      let(:expected)  { read_data.map { |hsh| record_class.new(hsh) } }

      it { expect(builder.create).to be == expected }

      it 'should persist the record' do
        expect(builder.create).to all satisfy(&:persisted?)
      end

      it { expect { builder.create }.to change(record_class, :count).by(1) }

      context 'when the record already exists' do
        let(:factory_name) do
          record_class.name.split('::').last.underscore.singularize.intern
        end
        let(:existing_record) do
          FactoryBot.build(factory_name, id: read_data.dig(0, 'id'))
        end

        before(:example) { existing_record.save! }

        it { expect(builder.create).to be == expected }

        it 'should persist the record' do
          expect(builder.create).to all satisfy(&:persisted?)
        end

        it { expect { builder.create }.not_to change(record_class, :count) }

        it 'should update the record' do
          builder.create

          expect(existing_record.reload).to match_attributes(read_data[0])
        end
      end
    end

    context 'when the data has many items' do
      include_context 'when data is defined for the resource'

      let(:read_data) { data }
      let(:expected)  { read_data.map { |hsh| record_class.new(hsh) } }

      it { expect(builder.create).to be == expected }

      it 'should persist the record' do
        expect(builder.create).to all satisfy(&:persisted?)
      end

      it { expect { builder.create }.to change(record_class, :count).by(3) }

      context 'when one of the records already exists' do
        let(:factory_name) do
          record_class.name.split('::').last.underscore.singularize.intern
        end
        let(:existing_record) do
          FactoryBot.build(factory_name, id: read_data.dig(1, 'id'))
        end

        before(:example) { existing_record.save! }

        it { expect(builder.create).to be == expected }

        it 'should persist the records' do
          expect(builder.create).to all satisfy(&:persisted?)
        end

        it { expect { builder.create }.to change(record_class, :count).by(2) }

        it 'should update the record' do
          builder.create

          expect(existing_record.reload).to match_attributes(read_data[1])
        end
      end

      context 'when each of the records already exist' do
        let(:factory_name) do
          record_class.name.split('::').last.underscore.singularize.intern
        end
        let(:existing_records) do
          read_data.map do |attributes|
            FactoryBot.build(factory_name, id: attributes.dig('id'))
          end
        end

        before(:example) { existing_records.each(&:save!) }

        it { expect(builder.create).to be == expected }

        it 'should persist the records' do
          expect(builder.create).to all satisfy(&:persisted?)
        end

        it { expect { builder.create }.not_to change(record_class, :count) }

        it 'should update the records' do # rubocop:disable RSpec/ExampleLength
          builder.create

          expect(existing_records.map(&:reload))
            .to all(
              satisfy do |record|
                attributes = read_data.find { |hsh| hsh['id'] == record.id }

                match_attributes(attributes)
              end
            )
        end
      end
    end
  end

  describe '#environment' do
    include_examples 'should have reader', :environment, 'fixtures'

    wrap_context 'with a custom environment' do
      it { expect(builder.environment).to be environment }
    end
  end

  describe '#read' do
    let(:data)    { [] }
    let(:options) { {} }
    let(:loader) do
      instance_double(Fixtures::Loader, call: nil, data: data, options: options)
    end
    let(:resource_name) { record_class.name.underscore.pluralize }

    before(:example) do
      allow(Fixtures::Loader).to receive(:new).and_return(loader)

      allow(loader).to receive(:call).and_return(loader)
    end

    it 'should define the method' do
      expect(builder)
        .to respond_to(:read)
        .with(0).arguments
        .and_keywords(:count, :except)
    end

    it 'should delegate to a loader' do
      builder.read

      expect(Fixtures::Loader).to have_received(:new).with(
        environment:   environment,
        resource_name: resource_name
      )
    end

    it 'should call the loader' do
      builder.read

      expect(loader).to have_received(:call).with(no_args)
    end

    it 'should return the data' do
      expect(builder.read).to be == data
    end

    describe 'with count: 0' do
      it 'should return an empty array' do
        expect(builder.read count: 0).to be == []
      end
    end

    describe 'with count: 1' do
      let(:error_message) do
        'Requested 1 manufacturer, but the data is empty'
      end

      it 'should raise an error' do
        expect { builder.read count: 1 }
          .to raise_error Fixtures::NotEnoughFixturesError, error_message
      end
    end

    describe 'with count: 3' do
      let(:error_message) do
        'Requested 3 manufacturers, but the data is empty'
      end

      it 'should raise an error' do
        expect { builder.read count: 3 }
          .to raise_error Fixtures::NotEnoughFixturesError, error_message
      end
    end

    describe 'with except: array' do
      it 'should return the data' do
        expect(builder.read except: %w[id description]).to be == data
      end
    end

    describe 'with except: value' do
      it 'should return the data' do
        expect(builder.read except: 'description').to be == data
      end
    end

    wrap_context 'when data is defined for the resource' do
      it 'should return the data' do
        expect(builder.read).to be == data
      end

      describe 'with count: 0' do
        it 'should return an empty array' do
          expect(builder.read count: 0).to be == []
        end
      end

      describe 'with count: 1' do
        it 'should return the first item' do
          expect(builder.read count: 1).to be == data[0...1]
        end
      end

      describe 'with count: 3' do
        it 'should return the first 3 items' do
          expect(builder.read count: 3).to be == data[0...3]
        end
      end

      describe 'with count: 6' do
        let(:error_message) do
          'Requested 6 manufacturers, but there are only 3 manufacturers'
        end

        it 'should raise an error' do
          expect { builder.read count: 6 }
            .to raise_error Fixtures::NotEnoughFixturesError, error_message
        end
      end

      describe 'with except: array' do
        let(:expected) do
          data.map { |item| item.except('id', 'description') }
        end

        it 'should filter the data' do
          expect(builder.read except: %w[id description]).to be == expected
        end
      end

      describe 'with except: value' do
        let(:expected) do
          data.map { |item| item.except('description') }
        end

        it 'should filter the data' do
          expect(builder.read except: 'description').to be == expected
        end
      end

      wrap_context 'when options are defined for the resource' do
        let(:expected) do
          data.map do |item|
            item.merge('name' => item['name'].upcase)
          end
        end

        it 'should map the data' do
          expect(builder.read).to be == expected
        end
      end
    end

    wrap_context 'when options are defined for the resource' do
      it 'should return the data' do
        expect(builder.read).to be == data
      end
    end
  end

  describe '#record_class' do
    include_examples 'should have reader', :record_class, -> { record_class }
  end
end
