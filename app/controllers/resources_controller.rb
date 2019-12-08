# frozen_string_literal: true

require 'forwardable'

require 'operations/steps'
require 'resource'
require 'responders/html'

# rubocop:disable Metrics/ClassLength

# Abstract base class for API resource controllers that delegate their actions
# to pre-defined operations.
class ResourcesController < ApplicationController
  extend  Forwardable
  include Operations::Steps::Mixin

  SORT_DIRECTIONS = {
    'asc'        => 'asc',
    'ascending'  => 'asc',
    'desc'       => 'desc',
    'descending' => 'desc'
  }.freeze
  private_constant :SORT_DIRECTIONS

  def create
    dispatch_response(result: create_resource, status: :created)
  end

  def destroy
    dispatch_response(result: destroy_resource)
  end

  def edit
    dispatch_response(result: edit_resource)
  end

  def index
    dispatch_response(result: index_resources)
  end

  def new
    dispatch_response(result: new_resource)
  end

  def show
    dispatch_response(result: show_resource)
  end

  def update
    dispatch_response(result: update_resource)
  end

  private

  def_delegators :resource, :operation_factory

  def create_resource
    create_operation = operation_factory.create

    steps do
      attributes = step :require_resource_params

      create_operation.call(attributes)
    end
  end

  def default_order
    {}
  end

  def destroy_resource
    find_operation    = operation_factory.find_one
    destroy_operation = operation_factory.destroy

    steps do
      resource = step find_operation.call(resource_id)

      step destroy_operation.call(resource)
    end
  end

  def dispatch_response(action: nil, result:, status: nil)
    responder.call(
      generate_response(result),
      action: action || action_name.intern,
      status: status
    )
  end

  def edit_resource
    find_operation = operation_factory.find_one

    find_operation.call(resource_id)
  end

  def failure(error)
    Cuprum::Result.new(error: error)
  end

  def generate_response(result)
    Cuprum::Result.new(
      error:  result.error,
      status: result.status,
      value:  generate_response_value(result)
    )
  end

  def generate_response_value(result)
    resources.merge(normalize_response_value(result.value))
  end

  def index_params
    @index_params ||=
      params
      .permit(:order)
      .to_hash
  end

  def index_order
    index_params.fetch('order', default_order)
  end

  def index_resources
    find_operation = operation_factory.find_matching

    steps do
      order = step :normalize_sort, index_order

      step find_operation.call(order: order)
    end
  end

  def invalid_order_result
    error = Errors::InvalidParameters.new(errors: [['order', 'is invalid']])

    failure(error)
  end

  def new_resource
    build_operation = operation_factory.build

    build_operation.call
  end

  def normalize_response_value(value)
    case value
    when nil
      {}
    when Hash
      value
    when Array
      { resource.plural_name => value }
    else
      { resource.singular_name => value }
    end
  end

  def normalize_sort(order)
    return {} if order.nil?

    return order if order.is_a?(Hash)

    return invalid_order_result unless order.is_a?(String)

    order.split('::').each.with_object({}) do |str, hsh|
      key, dir = str.split(':')

      dir = SORT_DIRECTIONS.fetch(dir, nil)

      return invalid_order_result if key.blank? || dir.blank?

      hsh[key] = dir
    end
  end

  def permitted_attributes
    []
  end

  def require_resource_params
    return success(resource_params) unless resource_params.empty?

    error =
      if permitted_attributes.empty?
        Cuprum::Error
          .new(message: 'No attributes are permitted for the current action')
      else
        Errors::InvalidParameters
          .new(errors: [[resource.singular_name, "can't be blank"]])
      end

    failure(error)
  end

  def resource
    @resource ||= Resource.new(nil, name: 'resource')
  end

  def resource_id
    params['id']&.to_i
  end

  def resource_params
    @resource_params ||=
      params
      .fetch(resource.singular_name, {})
      .permit(*permitted_attributes)
      .to_hash
  end

  def resources
    @resources ||= {}
  end

  def responder
    @responder ||= Responders::Html.new(self, resource: resource)
  end

  def show_resource
    find_operation = operation_factory.find_one

    find_operation.call(resource_id)
  end

  def success(value)
    Cuprum::Result.new(value: value)
  end

  def update_resource
    find_operation   = operation_factory.find_one
    update_operation = operation_factory.update

    steps do
      resource   = step find_operation.call(resource_id)
      attributes = step :require_resource_params

      update_operation.call(resource, attributes)
    end
  end
end
# rubocop:enable Metrics/ClassLength
