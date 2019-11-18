# frozen_string_literal: true

require 'fixtures'

module Fixtures
  # Fixture loader class that finds the data (and options, if any) for a given
  # environment and resource.
  class Loader
    def initialize(environment:, resource_name:)
      @environment   = environment
      @resource_name = resource_name
    end

    attr_reader :data

    attr_reader :environment

    attr_reader :options

    attr_reader :resource_name

    def call
      @data    = read_data
      @options = read_options

      self
    end

    def exist?
      data_dir_exists? || data_file_exists?
    end

    private

    def data_dir_exists?
      File.exist?(data_dir_path) && File.directory?(data_dir_path)
    end

    def data_dir_path
      @data_dir_path ||= Rails.root.join 'data', environment, resource_name
    end

    def data_file_exists?
      File.exist?(data_file_path)
    end

    def data_file_path
      @data_file_path ||=
        Rails.root.join 'data', environment, "#{resource_name}.yml"
    end

    def options_file_exists?
      options_file_path && File.exist?(options_file_path)
    end

    def options_file_path
      return @options_file_path unless @options_file_path.nil?

      @options_file_path =
        if data_dir_exists?
          Rails.root.join 'data', environment, resource_name, '_options.yml'
        elsif data_file_exists?
          Rails.root.join 'data', environment, "#{resource_name}_options.yml"
        else
          false
        end
    end

    def read_data
      return read_data_dir  if data_dir_exists?
      return read_data_file if data_file_exists?

      message =
        "Unable to load fixtures from /data/#{environment}/#{resource_name}"

      raise Fixtures::FixturesNotDefinedError, message
    end

    def read_data_dir
      Dir.entries(data_dir_path).each.with_object([]) do |file_name, data|
        next if file_name.start_with?('_')

        file_path = File.join(data_dir_path, file_name)
        file_data = YAML.safe_load(File.read(file_path))

        file_data.is_a?(Array) ? data.concat(file_data) : data << file_data
      end
    end

    def read_data_file
      YAML.safe_load(File.read(data_file_path))
    end

    def read_options
      return {} unless options_file_exists?

      YAML.safe_load(File.read(options_file_path))
    end
  end
end
