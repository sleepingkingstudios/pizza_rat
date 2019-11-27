# frozen_string_literal: true

require 'operations/records/factory'

# Value object representing a RESTful resource.
class Resource
  def initialize(record_class, name: nil, plural_name: nil, singular_name: nil)
    validate_arguments(name: name, record_class: record_class)

    @record_class  = record_class
    @name          =
      normalize_name(name.presence || record_class.name.split('::').last)
    @plural_name   = plural_name ? normalize_name(plural_name) : @name.pluralize
    @singular_name =
      singular_name ? normalize_name(singular_name) : @name.singularize
  end

  attr_reader :name

  attr_reader :plural_name

  attr_reader :record_class

  attr_reader :singular_name

  def index_path(**_options)
    "/#{plural_name}"
  end

  def operation_factory
    Operations::Records::Factory.for(record_class)
  end

  def show_path(record, **_options)
    "#{index_path}/#{record.id}"
  end

  private

  def normalize_name(value)
    return value.underscore if value.is_a?(String)

    return value.to_s.underscore if value.is_a?(Symbol)

    raise ArgumentError, 'name must be a String or Symbol', caller[1..-1]
  end

  def validate_arguments(name:, record_class:)
    return if record_class

    return unless name.blank?

    raise ArgumentError, 'must provide a record class or a name', caller[1..-1]
  end
end
