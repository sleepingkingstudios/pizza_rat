# frozen_string_literal: true

require 'rails_helper'

require 'fixtures/loader'

RSpec.describe Fixtures::Loader do
  shared_context 'when data is defined for the resource' do
    let(:data) do
      [
        {
          'id'               => '00000000-0000-0000-0000-000000000000',
          'name'             => 'Star Wars',
          'publication_date' => '1977-05-25',
          'publisher_name'   => 'Lucasfilm'
        },
        {
          'id'               => '00000000-0000-0000-0000-000000000001',
          'name'             => 'The Empire Strikes Back',
          'publication_date' => '1980-06-20',
          'publisher_name'   => 'Lucasfilm'
        },
        {
          'id'               => '00000000-0000-0000-0000-000000000002',
          'name'             => 'Return of the Jedi',
          'publication_date' => '1983-05-25',
          'publisher_name'   => 'Lucasfilm'
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
  end

  subject(:loader) do
    described_class.new(
      environment:   environment,
      resource_name: resource_name
    )
  end

  let(:environment)   { 'fixtures' }
  let(:resource_name) { 'publications' }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:environment, :resource_name)
    end
  end

  # rubocop:disable RSpec/SubjectStub
  describe '#call' do
    let(:data) { {} }

    it { expect(loader).to respond_to(:call).with(0).arguments }

    context 'when the data does not exist' do
      let(:error_message) do
        "Unable to load fixtures from /data/#{environment}/#{resource_name}"
      end

      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(false)
      end

      it 'should raise an error' do
        expect { loader.call }
          .to raise_error Fixtures::FixturesNotDefinedError, error_message
      end
    end

    context 'when the data directory exists' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(true)
        allow(loader).to receive(:data_file_exists?).and_return(false)
        allow(loader).to receive(:options_file_exists?).and_return(false)
        allow(loader).to receive(:read_data_dir).and_return(data)
      end

      it { expect(loader.call).to be loader }

      it { expect { loader.call }.to change(loader, :data).to be == data }

      it { expect { loader.call }.to change(loader, :options).to be == {} }

      wrap_context 'when data is defined for the resource' do
        it { expect { loader.call }.to change(loader, :data).to be == data }

        context 'when the options file exists' do
          include_context 'when options are defined for the resource'

          before(:example) do
            allow(loader).to receive(:options_file_exists?).and_return(true)
            allow(loader).to receive(:read_options).and_return(options)
          end

          it 'should load the options' do
            expect { loader.call }.to change(loader, :options).to be == options
          end
        end
      end

      context 'when the options file exists' do
        include_context 'when options are defined for the resource'

        before(:example) do
          allow(loader).to receive(:options_file_exists?).and_return(true)
          allow(loader).to receive(:read_options).and_return(options)
        end

        it 'should load the options' do
          expect { loader.call }.to change(loader, :options).to be == options
        end
      end
    end

    context 'when the data file exists' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(true)
        allow(loader).to receive(:options_file_exists?).and_return(false)
        allow(loader).to receive(:read_data_file).and_return(data)
      end

      it { expect(loader.call).to be loader }

      it { expect { loader.call }.to change(loader, :data).to be == data }

      it { expect { loader.call }.to change(loader, :options).to be == {} }

      wrap_context 'when data is defined for the resource' do
        it { expect { loader.call }.to change(loader, :data).to be == data }

        context 'when the options file exists' do
          include_context 'when options are defined for the resource'

          before(:example) do
            allow(loader).to receive(:options_file_exists?).and_return(true)
            allow(loader).to receive(:read_options).and_return(options)
          end

          it 'should load the options' do
            expect { loader.call }.to change(loader, :options).to be == options
          end
        end
      end

      context 'when the options file exists' do
        include_context 'when options are defined for the resource'

        before(:example) do
          allow(loader).to receive(:options_file_exists?).and_return(true)
          allow(loader).to receive(:read_options).and_return(options)
        end

        it 'should load the options' do
          expect { loader.call }.to change(loader, :options).to be == options
        end
      end
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#data' do
    include_examples 'should define reader', :data, nil
  end

  describe '#data_dir_exists?' do
    let(:dir_name) { File.join environment, resource_name }
    let(:dir_path) { Rails.root.join 'data', dir_name }

    before(:example) do
      allow(File).to receive(:exist?).with(dir_path)
      allow(File).to receive(:directory?).with(dir_path)
    end

    it 'should define the private method' do
      expect(loader).to respond_to(:data_dir_exists?, true).with(0).arguments
    end

    it 'should check if the directory exists' do
      loader.send :data_dir_exists?

      expect(File).to have_received(:exist?).with(dir_path)
    end

    it 'should check if the directory is a directory' do
      allow(File).to receive(:exist?).with(dir_path).and_return(true)

      loader.send :data_dir_exists?

      expect(File).to have_received(:directory?).with(dir_path)
    end

    context 'when the directory does not exist' do
      before(:example) do
        allow(File).to receive(:exist?).with(dir_path).and_return(false)
      end

      it { expect(loader.send :data_dir_exists?).to be false }
    end

    context 'when the directory is not a directory' do
      before(:example) do
        allow(File).to receive(:exist?).with(dir_path).and_return(true)
        allow(File).to receive(:directory?).with(dir_path).and_return(false)
      end

      it { expect(loader.send :data_dir_exists?).to be false }
    end

    context 'when the directory exists and is a directory' do
      before(:example) do
        allow(File).to receive(:exist?).with(dir_path).and_return(true)
        allow(File).to receive(:directory?).with(dir_path).and_return(true)
      end

      it { expect(loader.send :data_dir_exists?).to be true }
    end
  end

  describe '#data_file_exists?' do
    let(:file_name) { File.join environment, "#{resource_name}.yml" }
    let(:file_path) { Rails.root.join 'data', file_name }

    before(:example) do
      allow(File).to receive(:exist?).with(file_path)
    end

    it 'should define the private method' do
      expect(loader).to respond_to(:data_file_exists?, true).with(0).arguments
    end

    context 'when the file does not exist' do
      before(:example) do
        allow(File).to receive(:exist?).with(file_path).and_return(false)
      end

      it { expect(loader.send :data_file_exists?).to be false }
    end

    context 'when the file exists' do
      before(:example) do
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it { expect(loader.send :data_file_exists?).to be true }
    end
  end

  # rubocop:disable RSpec/SubjectStub
  describe '#exist?' do
    it { expect(loader).to respond_to(:exist?).with(0).arguments }

    context 'when the data does not exist' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(false)
      end

      it { expect(loader.exist?).to be false }
    end

    context 'when the data directory exists' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(true)
        allow(loader).to receive(:data_file_exists?).and_return(false)
      end

      it { expect(loader.exist?).to be true }
    end

    context 'when the data file exists' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(true)
      end

      it { expect(loader.exist?).to be true }
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#environment' do
    include_examples 'should define reader', :environment, -> { environment }
  end

  describe '#options' do
    include_examples 'should define reader', :options, nil
  end

  # rubocop:disable RSpec/SubjectStub
  describe '#options_file_exists?' do
    it 'should define the private method' do
      expect(loader)
        .to respond_to(:options_file_exists?, true)
        .with(0).arguments
    end

    context 'when the data does not exist' do
      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(false)
      end

      it { expect(loader.send :options_file_exists?).to be false }
    end

    context 'when the data directory exists' do
      let(:opts_name) do
        File.join environment, resource_name, '_options.yml'
      end
      let(:opts_path) { Rails.root.join 'data', opts_name }

      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(true)
        allow(loader).to receive(:data_file_exists?).and_return(false)

        allow(File).to receive(:exist?).with(opts_path).and_return(false)
      end

      it { expect(loader.send :options_file_exists?).to be false }

      context 'when the options file exists' do
        before(:example) do
          allow(File).to receive(:exist?).with(opts_path).and_return(true)
        end

        it { expect(loader.send :options_file_exists?).to be true }
      end
    end

    context 'when the data file exists' do
      let(:opts_name) do
        File.join environment, "#{resource_name}_options.yml"
      end
      let(:opts_path) { Rails.root.join 'data', opts_name }

      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(true)

        allow(File).to receive(:exist?).with(opts_path).and_return(false)
      end

      it { expect(loader.send :options_file_exists?).to be false }

      context 'when the options file exists' do
        before(:example) do
          allow(File).to receive(:exist?).with(opts_path).and_return(true)
        end

        it { expect(loader.send :options_file_exists?).to be true }
      end
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#read_data_dir' do
    let(:dir_name)  { File.join environment, resource_name }
    let(:dir_path)  { Rails.root.join 'data', dir_name }
    let(:dir_files) { {} }

    before(:example) do
      allow(Dir)
        .to receive(:entries)
        .with(dir_path)
        .and_return(dir_files.keys)

      dir_files.each do |file_name, file_data|
        file_path = File.join(dir_path, file_name)

        allow(File).to receive(:read).with(file_path).and_return(file_data)
      end
    end

    it 'should define the private method' do
      expect(loader).to respond_to(:read_data_dir, true).with(0).arguments
    end

    context 'when the data dir is empty' do
      before(:example) do
        allow(Dir).to receive(:entries).with(dir_path).and_return([])
      end

      it { expect(loader.send :read_data_dir).to be == [] }
    end

    context 'when the data dir has individual files' do
      include_context 'when data is defined for the resource'

      let(:dir_files) do
        data.map.with_object({}) do |item, hsh|
          file_name = "#{item['name'].underscore.tr(' ', '_')}.yml"

          hsh[file_name] = YAML.dump(item)
        end
      end

      it { expect(loader.send :read_data_dir).to be == data }

      context 'when the data dir has an options file' do
        include_context 'when options are defined for the resource'

        let(:dir_files) do
          super().merge('_options.yml' => YAML.dump(options))
        end

        it { expect(loader.send :read_data_dir).to be == data }
      end
    end

    context 'when the data dir has collection files' do
      include_context 'when data is defined for the resource'

      let(:dir_files) do
        data.map.with_object({}) do |item, hsh|
          file_name = "#{item['name'].underscore.tr(' ', '_')}.yml"

          hsh[file_name] = YAML.dump([item])
        end
      end

      it { expect(loader.send :read_data_dir).to be == data }

      context 'when the data dir has an options file' do
        include_context 'when options are defined for the resource'

        let(:dir_files) do
          super().merge('_options.yml' => YAML.dump(options))
        end

        it { expect(loader.send :read_data_dir).to be == data }
      end
    end
  end

  describe '#read_data_file' do
    include_context 'when data is defined for the resource'

    let(:file_name) { File.join environment, "#{resource_name}.yml" }
    let(:file_path) { Rails.root.join 'data', file_name }

    before(:example) do
      allow(File).to receive(:read).with(file_path).and_return(YAML.dump(data))
    end

    it 'should define the private method' do
      expect(loader).to respond_to(:read_data_file, true).with(0).arguments
    end

    it { expect(loader.send :read_data_file).to be == data }
  end

  # rubocop:disable RSpec/SubjectStub
  describe '#read_options' do
    include_context 'when options are defined for the resource'

    it 'should define the private method' do
      expect(loader).to respond_to(:read_options, true).with(0).arguments
    end

    context 'when the data directory exists' do
      let(:opts_name) do
        File.join environment, resource_name, '_options.yml'
      end
      let(:opts_path) { Rails.root.join 'data', opts_name }

      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(true)
        allow(loader).to receive(:data_file_exists?).and_return(false)
        allow(loader).to receive(:options_file_exists?).and_return(false)
      end

      it { expect(loader.send :read_options).to be == {} }

      context 'when the options file exists' do
        before(:example) do
          allow(loader).to receive(:options_file_exists?).and_return(true)

          allow(File)
            .to receive(:read)
            .with(opts_path)
            .and_return(YAML.dump(options))
        end

        it { expect(loader.send :read_options).to be == options }
      end
    end

    context 'when the data directory exists' do
      let(:opts_name) do
        File.join environment, "#{resource_name}_options.yml"
      end
      let(:opts_path) { Rails.root.join 'data', opts_name }

      before(:example) do
        allow(loader).to receive(:data_dir_exists?).and_return(false)
        allow(loader).to receive(:data_file_exists?).and_return(true)
        allow(loader).to receive(:options_file_exists?).and_return(false)
      end

      it { expect(loader.send :read_options).to be == {} }

      context 'when the options file exists' do
        before(:example) do
          allow(loader)
            .to receive(:options_file_exists?)
            .and_return(true)

          allow(File)
            .to receive(:read)
            .with(opts_path)
            .and_return(YAML.dump(options))
        end

        it { expect(loader.send :read_options).to be == options }
      end
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#resource_name' do
    include_examples 'should define reader',
      :resource_name,
      -> { resource_name }
  end
end
