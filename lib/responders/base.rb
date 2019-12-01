# frozen_string_literal: true

require 'forwardable'

require 'errors/failed_validation'
require 'errors/invalid_parameters'
require 'errors/not_found'
require 'resource'
require 'responders'

module Responders
  # Abstract base class for accepting a passing or failing Result and generating
  # a server response.
  class Base
    extend Forwardable

    def_delegators :@controller,
      :head,
      :redirect_to,
      :render

    # @param controller [ActionController::Base] The controller instance to
    #   handle the generated response.
    def initialize(controller, resource: nil)
      @controller = controller
      @resource   = resource || Resource.new(nil, name: 'resource')
    end

    # @return [ActionController::Base] the controller instance to handle the
    #   generated response.
    attr_reader :controller

    # @return [Hash] the options provided to #call.
    attr_reader :options

    attr_reader :resource

    def call(result, **options)
      @options = options

      result.success? ? respond_to_success(result) : respond_to_failure(result)
    end

    private

    def error_status(error)
      case error
      when Errors::FailedValidation
        :unprocessable_entity
      when Errors::InvalidParameters
        :bad_request
      when Errors::NotFound
        :not_found
      else
        :internal_server_error
      end
    end

    def respond_to_failure(result)
      head error_status(result.error)
    end

    def respond_to_success(_result)
      head options.fetch(:status, :ok)
    end
  end
end
