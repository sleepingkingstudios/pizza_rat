# frozen_string_literal: true

require 'cuprum/command_factory'

require 'operations/records'
require 'operations/records/assign'
require 'operations/records/build'
require 'operations/records/create'
require 'operations/records/destroy'
require 'operations/records/find_many'
require 'operations/records/find_matching'
require 'operations/records/find_one'
require 'operations/records/save'
require 'operations/records/update'

module Operations::Records
  # Command factory for generating record operations.
  class Factory < Cuprum::CommandFactory
    def self.for(record_class)
      record_class = record_class.constantize if record_class.is_a?(String)

      return record_class::Factory if record_class.const_defined?(:Factory)

      new(record_class)
    end

    def initialize(record_class)
      @record_class = record_class
    end

    attr_reader :record_class

    command_class(:assign) do
      Operations::Records::Assign.subclass(record_class)
    end

    command_class(:build) do
      Operations::Records::Build.subclass(record_class)
    end

    command_class(:create) do
      Operations::Records::Create.subclass(record_class)
    end

    command_class(:destroy) do
      Operations::Records::Destroy.subclass(record_class)
    end

    command_class(:find_many) do
      Operations::Records::FindMany.subclass(record_class)
    end

    command_class(:find_matching) do
      Operations::Records::FindMatching.subclass(record_class)
    end

    command_class(:find_one) do
      Operations::Records::FindOne.subclass(record_class)
    end

    command_class(:save) do
      Operations::Records::Save.subclass(record_class)
    end

    command_class(:update) do
      Operations::Records::Update.subclass(record_class)
    end
  end
end
