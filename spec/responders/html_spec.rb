# frozen_string_literal: true

require 'rails_helper'

require 'responders/html'

RSpec.describe Responders::Html do
  subject(:responder) { described_class.new(controller, resource: resource) }

  let(:controller) { instance_double(ApplicationController) }
  let(:resource)   { Resource.new(Spec::Manufacturer) }

  describe '#call' do
    shared_examples 'should handle a FailedValidation error' do
      describe 'with a failing result with error: FailedValidation' do
        let(:manufacturer) { FactoryBot.build(:manufacturer) }
        let(:error) do
          Errors::FailedValidation.new(record: manufacturer)
        end
        let(:result) do
          Cuprum::Result.new(
            value: { 'manufacturer' => manufacturer }, error: error
          )
        end
        let(:locals) { { data: result.value, error: error } }

        it 'should render 422 Unprocessable Entity with the error details' do
          responder.call(result, action: action)

          expect(controller)
            .to have_received(:render)
            .with(template, locals: locals, status: :unprocessable_entity)
        end

        describe 'with status: value' do
          let(:options) { { status: :forbidden } }

          it 'should render 422 Unprocessable Entity with the error details' do
            responder.call(result, action: action)

            expect(controller)
              .to have_received(:render)
              .with(template, locals: locals, status: :unprocessable_entity)
          end
        end
      end
    end

    shared_examples 'should handle an InvalidParameters error' do
      describe 'with a failing result with error: InvalidParameters' do
        let(:error)  { Errors::InvalidParameters.new(errors: []) }
        let(:result) { Cuprum::Result.new(error: error) }
        let(:locals) { { data: {}, error: error } }

        it 'should render 400 Bad Request with the error details' do
          responder.call(result, action: action)

          expect(controller)
            .to have_received(:render)
            .with(template, locals: locals, status: :bad_request)
        end

        describe 'with status: value' do
          let(:options) { { status: :forbidden } }

          it 'should render 400 Bad Request with the error details' do
            responder.call(result, action: action, status: :forbidden)

            expect(controller)
              .to have_received(:render)
              .with(template, locals: locals, status: :bad_request)
          end
        end
      end
    end

    shared_examples 'should handle a NotFound error' do
      describe 'with a failing result with error: NotFound' do
        let(:error) do
          Errors::NotFound.new(
            attributes:   { 'id' => 0 },
            record_class: Spec::Manufacturer
          )
        end
        let(:result) { Cuprum::Result.new(error: error) }

        include_examples 'should redirect to the index resources path'
      end
    end

    shared_examples 'should handle an unknown error' do
      describe 'with a failing result with error: unknown error' do
        let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result) { Cuprum::Result.new(error: error) }
        let(:locals) do
          satisfy do |hsh|
            expect(hsh).to be_a Hash
            expect(hsh.keys).to be == %i[data error]
            expect(hsh.fetch :data).to be == {}
            expect(hsh.fetch :error).to be == Cuprum::Error.new(
              message: 'Something went wrong when processing the request.'
            )
          end
        end

        it 'should render 500 Internal Server Error with a generic error' do
          responder.call(result, action: action)

          expect(controller)
            .to have_received(:render)
            .with(template, locals: locals, status: :internal_server_error)
        end

        describe 'with status: value' do
          let(:options) { { status: :forbidden } }

          it 'should render 500 Internal Server Error with a generic error' do
            responder.call(result, action: action)

            expect(controller)
              .to have_received(:render)
              .with(template, locals: locals, status: :internal_server_error)
          end
        end
      end
    end

    shared_examples 'should redirect to the index resources path' do
      let(:index_path) { '/manufacturers' }

      it 'should redirect to the index resources path' do
        responder.call(result, action: action, **options)

        expect(controller).to have_received(:redirect_to).with(index_path)
      end
    end

    shared_examples 'should render the template and assign the data' \
    do |default_status: :ok|
      let(:locals) { { data: (result.value || {}), error: nil } }

      it 'should render 200 OK and serialize the resource' do
        responder.call(result, action: action, **options)

        expect(controller)
          .to have_received(:render)
          .with(template, locals: locals, status: default_status)
      end

      describe 'with status: value' do
        let(:status) { :accepted }

        it 'should render 200 OK and serialize the resource' do
          responder.call(result, action: action, status: status, **options)

          expect(controller)
            .to have_received(:render)
            .with(template, locals: locals, status: status)
        end
      end
    end

    shared_examples 'should require a valid resource' \
    do |handle_failure: nil, handle_success: nil|
      handle_failure ||= lambda do
        include_examples 'should redirect to the index resources path'
      end

      handle_success ||= lambda do
        include_examples 'should render the template and assign the data'
      end

      shared_examples 'should dispatch a failure response' do
        instance_exec(&handle_failure)
      end

      shared_examples 'should dispatch a success response' do
        instance_exec(&handle_success)
      end

      describe 'with a passing result with a nil value' do
        let(:result) { Cuprum::Result.new(value: nil) }
        let(:locals) { { data: {}, error: nil } }

        include_examples 'should dispatch a failure response'
      end

      describe 'with a passing result with an empty Hash value' do
        let(:result) { Cuprum::Result.new(value: {}) }
        let(:locals) { { data: result.value, error: nil } }

        include_examples 'should dispatch a failure response'
      end

      describe 'with a passing result with a non-matching singular resource' do
        let(:manufacturer) { FactoryBot.create(:manufacturer) }
        let(:result) do
          Cuprum::Result.new(value: { 'current_manufacturer' => manufacturer })
        end

        include_examples 'should dispatch a failure response'
      end

      describe 'with a passing result with a matching singular resource' do
        let(:manufacturer) { FactoryBot.create(:manufacturer) }
        let(:result) do
          Cuprum::Result.new(value: { 'manufacturer' => manufacturer })
        end
        let(:locals) { { data: result.value, error: nil } }

        include_examples 'should dispatch a success response'
      end

      describe 'with a passing result with multiple resources' do
        let(:manufacturer)       { FactoryBot.create(:manufacturer) }
        let(:employees) { Array.new(3) { {} } }
        let(:result) do
          Cuprum::Result.new(
            value: { 'manufacturer' => manufacturer, 'employees' => employees }
          )
        end

        include_examples 'should dispatch a success response'
      end

      describe 'with require_resource: false' do
        let(:options) { super().merge(require_resource: false) }

        describe 'with a passing result with a nil value' do
          let(:result) { Cuprum::Result.new(value: nil) }
          let(:locals) { { data: {}, error: nil } }

          include_examples 'should dispatch a success response'
        end

        describe 'with a passing result with an empty Hash value' do
          let(:result) { Cuprum::Result.new(value: {}) }
          let(:locals) { { data: result.value, error: nil } }

          include_examples 'should dispatch a success response'
        end

        describe 'with a passing result with a non-matching singular resource' \
        do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(
              value: { 'current_manufacturer' => manufacturer }
            )
          end

          include_examples 'should dispatch a success response'
        end
      end

      describe 'with resource_key: value' do
        let(:options) { super().merge(resource_key: 'current_manufacturer') }

        describe 'with a passing result with a non-matching singular resource' \
        do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(value: { 'manufacturer' => manufacturer })
          end

          include_examples 'should dispatch a failure response'
        end

        describe 'with a passing result with a matching singular resource' do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(
              value: { 'current_manufacturer' => manufacturer }
            )
          end
          let(:locals) { { data: result.value, error: nil } }

          include_examples 'should dispatch a success response'
        end
      end
    end

    shared_examples 'should not require a valid resource' \
    do |handle_failure: nil, handle_success: nil|
      handle_failure ||= lambda do
        include_examples 'should redirect to the index resources path'
      end

      handle_success ||= lambda do
        include_examples 'should render the template and assign the data'
      end

      shared_examples 'should dispatch a failure response' do
        instance_exec(&handle_failure)
      end

      shared_examples 'should dispatch a success response' do
        instance_exec(&handle_success)
      end

      describe 'with a passing result with a nil value' do
        let(:result) { Cuprum::Result.new(value: nil) }
        let(:locals) { { data: {}, error: nil } }

        include_examples 'should dispatch a success response'
      end

      describe 'with a passing result with an empty Hash value' do
        let(:result) { Cuprum::Result.new(value: {}) }
        let(:locals) { { data: result.value, error: nil } }

        include_examples 'should dispatch a success response'
      end

      describe 'with a passing result with a non-matching singular resource' do
        let(:manufacturer) { FactoryBot.create(:manufacturer) }
        let(:result) do
          Cuprum::Result.new(value: { 'current_manufacturer' => manufacturer })
        end

        include_examples 'should dispatch a success response'
      end

      describe 'with a passing result with a matching singular resource' do
        let(:manufacturer) { FactoryBot.create(:manufacturer) }
        let(:result) do
          Cuprum::Result.new(value: { 'manufacturer' => manufacturer })
        end
        let(:locals) { { data: result.value, error: nil } }

        include_examples 'should dispatch a success response'
      end

      describe 'with a passing result with multiple resources' do
        let(:manufacturer)       { FactoryBot.create(:manufacturer) }
        let(:employees) { Array.new(3) { {} } }
        let(:result) do
          Cuprum::Result.new(
            value: { 'manufacturer' => manufacturer, 'employees' => employees }
          )
        end

        include_examples 'should dispatch a success response'
      end

      describe 'with require_resource: true' do
        let(:options) { super().merge(require_resource: true) }

        describe 'with a passing result with a nil value' do
          let(:result) { Cuprum::Result.new(value: nil) }
          let(:locals) { { data: {}, error: nil } }

          include_examples 'should dispatch a failure response'
        end

        describe 'with a passing result with an empty Hash value' do
          let(:result) { Cuprum::Result.new(value: {}) }
          let(:locals) { { data: result.value, error: nil } }

          include_examples 'should dispatch a failure response'
        end

        describe 'with a passing result with a non-matching singular resource' \
        do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(
              value: { 'current_manufacturer' => manufacturer }
            )
          end

          include_examples 'should dispatch a failure response'
        end

        describe 'with a passing result with a matching singular resource' do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(value: { 'manufacturer' => manufacturer })
          end
          let(:locals) { { data: result.value, error: nil } }

          include_examples 'should dispatch a success response'
        end
      end

      describe 'with resource_key: value and require_resource: true' do
        let(:options) do
          super().merge(
            require_resource: true,
            resource_key:     'current_manufacturer'
          )
        end

        describe 'with a passing result with a non-matching singular resource' \
        do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(value: { 'manufacturer' => manufacturer })
          end

          include_examples 'should dispatch a failure response'
        end

        describe 'with a passing result with a matching singular resource' do
          let(:manufacturer) { FactoryBot.create(:manufacturer) }
          let(:result) do
            Cuprum::Result.new(
              value: { 'current_manufacturer' => manufacturer }
            )
          end
          let(:locals) { { data: result.value, error: nil } }

          include_examples 'should dispatch a success response'
        end
      end
    end

    let(:options)  { {} }
    let(:template) { action }

    before(:example) do
      allow(controller).to receive(:redirect_to)
      allow(controller).to receive(:render)
    end

    it 'should define the method' do
      expect(responder)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:action, :status)
        .and_any_keywords
    end

    describe 'with action: :index' do
      let(:action) { :index }

      include_examples 'should handle an InvalidParameters error'

      include_examples 'should handle an unknown error'

      include_examples 'should not require a valid resource',
        handle_failure: lambda {
          let(:root_path) { '/' }

          it 'should redirect to the index resources path' do
            responder.call(result, action: action, **options)

            expect(controller).to have_received(:redirect_to).with(root_path)
          end
        }
    end

    describe 'with action: :new' do
      let(:action) { :new }

      include_examples 'should handle an unknown error'

      include_examples 'should require a valid resource'
    end

    describe 'with action: :create' do
      let(:action)   { :create }
      let(:template) { :new }

      include_examples 'should handle a FailedValidation error'

      include_examples 'should handle an InvalidParameters error'

      include_examples 'should handle an unknown error'

      include_examples 'should require a valid resource',
        handle_success: lambda {
          let(:index_path) { '/manufacturers' }
          let(:show_path)  { "/manufacturers/#{manufacturer.id}" }
          let(:expected_path) do
            resource =
              result
              .value
              &.fetch(options.fetch(:resource_key, 'manufacturer'), nil)

            resource ? show_path : index_path
          end

          it 'should redirect to the show resource path' do
            responder.call(result, action: action, **options)

            expect(controller)
              .to have_received(:redirect_to)
              .with(expected_path)
          end
        }
    end

    describe 'with action: :show' do
      let(:action) { :show }

      include_examples 'should handle an InvalidParameters error'

      include_examples 'should handle a NotFound error'

      include_examples 'should handle an unknown error'

      include_examples 'should require a valid resource'
    end

    describe 'with action: :edit' do
      let(:action) { :edit }

      include_examples 'should handle a NotFound error'

      include_examples 'should handle an unknown error'

      include_examples 'should require a valid resource'
    end

    describe 'with action: :update' do
      let(:action)   { :update }
      let(:template) { :edit }

      include_examples 'should handle a FailedValidation error',
        template: :edit

      include_examples 'should handle an InvalidParameters error',
        template: :edit

      include_examples 'should handle a NotFound error'

      include_examples 'should handle an unknown error',
        template: :edit

      include_examples 'should require a valid resource',
        handle_success: lambda {
          let(:index_path) { '/manufacturers' }
          let(:show_path)  { "/manufacturers/#{manufacturer.id}" }
          let(:expected_path) do
            resource =
              result
              .value
              &.fetch(options.fetch(:resource_key, 'manufacturer'), nil)

            resource ? show_path : index_path
          end

          it 'should redirect to the show resource path' do
            responder.call(result, action: action, **options)

            expect(controller)
              .to have_received(:redirect_to)
              .with(expected_path)
          end
        }
    end

    describe 'with action: :destroy' do
      let(:action) { :destroy }

      include_examples 'should handle a NotFound error'

      include_examples 'should handle an unknown error'

      include_examples 'should not require a valid resource',
        handle_success: lambda {
          include_examples 'should redirect to the index resources path'
        }
    end

    describe 'with an unknown action' do
      let(:action) { :publish }

      include_examples 'should handle a FailedValidation error'

      include_examples 'should handle an InvalidParameters error'

      include_examples 'should handle a NotFound error'

      include_examples 'should handle an unknown error'

      include_examples 'should not require a valid resource'
    end
  end

  describe '#controller' do
    include_examples 'should define reader', :controller, -> { controller }
  end
end
