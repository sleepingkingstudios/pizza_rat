# frozen_string_literal: true

require 'fixtures'

module Fixtures
  # Class to load data, or instantiate or persist records from stored fixture
  # files.
  class Builder
    # @param record_class [Class] The class of record that the operation's
    #   business logic operates on.
    # @param environment [String] The data directory to load from.
    def initialize(record_class, environment: 'fixtures')
      @record_class = record_class
      @environment  = environment
    end

    # @return [String] the data directory to load from.
    attr_reader :environment

    # @return [Class] the class of record that the operation's business logic
    #   operates on.
    attr_reader :record_class

    def build(**options)
      read(options).map { |attributes| build_record(attributes) }
    end

    def create(**options)
      read(options).map { |attributes| find_or_create_record(attributes) }
    end

    def read(count: nil, except: nil)
      loader = Fixtures::Loader.new(
        environment:   environment,
        resource_name: resource_name
      ).call

      data     = loader.data
      options  = loader.options
      mappings = options.fetch('mappings', {})

      process_data(data, count: count, except: except, mappings: mappings)
    end

    private

    def apply_count(data, count:)
      return data if count.nil?

      return data[0...count] if count <= data.size

      message = invalid_count_message(count, data.size)

      raise Fixtures::NotEnoughFixturesError, message
    end

    def apply_filters(data, except:)
      return data if except.blank?

      data.map { |hsh| hsh.except(*except) }
    end

    def apply_mappings(data, mappings:)
      return data if mappings.blank?

      mappings = generate_mappings(mappings)

      data.map do |raw|
        mappings.reduce(raw) { |item, directive| directive.call(item) }
      end
    end

    def build_record(attributes)
      record_class.new(attributes)
    end

    def create_record(attributes)
      build_record(attributes).tap(&:save!)
    end

    def find_or_create_record(attributes)
      record = find_record(attributes)

      if record
        update_record(record, attributes)
      else
        create_record(attributes)
      end
    end

    def find_record(attributes)
      record_class.where(id: attributes.fetch('id')).first
    end

    def generate_mappings(mappings)
      mappings.map do |mapping|
        type  = mapping.fetch('type').to_s.camelize
        opts  = mapping.fetch('options', {})
        klass = "Fixtures::Mappings::#{type}".constantize
        klass.new(opts.symbolize_keys)
      end
    end

    def invalid_count_message(expected, actual)
      message =
        "Requested #{expected} #{resource_name.singularize.pluralize(expected)}"

      if actual.zero?
        message + ', but the data is empty'
      else
        message +
          ", but there are only #{actual} " +
          resource_name.singularize.pluralize(actual)
      end
    end

    def process_data(data, count:, except:, mappings:)
      data = apply_count(data, count: count)
      data = apply_filters(data, except: Array(except).map(&:to_s))
      data = apply_mappings(data, mappings: mappings)

      data
    end

    def resource_name
      @resource_name ||= record_class.name.underscore.pluralize
    end

    def update_record(record, attributes)
      record.assign_attributes(attributes)

      record.tap(&:save!)
    end
  end
end
