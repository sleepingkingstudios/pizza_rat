# frozen_string_literal: true

# Namespace for fixtures, which handle reading data from a serialized source and
# hydrating the database.
module Fixtures
  autoload :Builder,  'fixtures/builder'
  autoload :Loader,   'fixtures/loader'
  autoload :Mappings, 'fixtures/mappings'

  class Error                   < StandardError; end
  class FixturesNotDefinedError < Fixtures::Error; end
  class NotEnoughFixturesError  < Fixtures::Error; end

  def self.build(record_class, environment: 'fixtures', **options)
    Builder.new(record_class, environment: environment).build(options)
  end

  def self.create(record_class, count: nil, environment: 'fixtures')
    Builder.new(record_class, environment: environment).create(count: count)
  end

  def self.exist?(record_class, environment: 'fixtures')
    resource_name = record_class.name.underscore.pluralize

    Fixtures::Loader.new(
      environment:   environment,
      resource_name: resource_name
    ).exist?
  end

  def self.read(record_class, count: nil, environment: 'fixtures')
    Builder.new(record_class, environment: environment).read(count: count)
  end
end
