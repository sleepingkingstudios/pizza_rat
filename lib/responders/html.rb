# frozen_string_literal: true

require 'responders/base'

module Responders
  # Accepts a passing or failing Result and generates an HTML response.
  class Html < Responders::Base
    ACTIONS_REQUIRING_RESOURCE = %i[new create show edit update].freeze
    private_constant :ACTIONS_REQUIRING_RESOURCE

    def call(result, action:, **options)
      @action = action.intern

      super
    end

    def_delegators :@resource,
      :index_path,
      :show_path

    private

    attr_reader :action

    def generic_error
      Cuprum::Error.new(
        message: 'Something went wrong when processing the request.'
      )
    end

    def options_for_failing_result(result)
      {
        locals: {
          data:  result.value || {},
          error: serialize_error(result.error)
        },
        status: error_status(result.error)
      }
    end

    def options_for_passing_result(result)
      {
        locals: { data: (result.value || {}), error: nil },
        status: options.fetch(:status, :ok)
      }
    end

    def require_resource?
      options.fetch(:require_resource) do
        ACTIONS_REQUIRING_RESOURCE.include?(action)
      end
    end

    def resource_key
      options.fetch(:resource_key, resource.singular_name)
    end

    def respond_to_failure(result)
      if result.error.is_a?(Errors::NotFound) && action != :index
        redirect_to(index_path)
      end

      render template_for(action), options_for_failing_result(result)
    end

    def root_path
      '/'
    end

    def respond_to_success(result)
      with_resource(result) do |resource|
        case action
        when :create, :update
          redirect_to(resource ? show_path(resource) : index_path)
        when :destroy
          redirect_to(index_path)
        else
          render action, options_for_passing_result(result)
        end
      end
    end

    def serialize_error(error)
      case error
      when Errors::FailedValidation, Errors::InvalidParameters, Errors::NotFound
        error
      else
        generic_error
      end
    end

    def template_for(action)
      case action
      when :create
        :new
      when :update
        :edit
      else
        action
      end
    end

    def with_resource(result)
      resource = result.value&.fetch(resource_key, nil)

      if resource || !require_resource?
        yield resource
      else
        redirect_to(action == :index ? root_path : index_path)
      end
    end
  end
end
