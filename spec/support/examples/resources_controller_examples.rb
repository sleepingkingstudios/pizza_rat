# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module ResourcesControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with a params hash' do
      let(:params) { {} }

      before(:example) do
        allow(controller).to receive(:params) do
          ActionController::Parameters.new(params)
        end
      end
    end

    shared_examples 'should define action' \
    do |action_name, collection: false, status: nil|
      operation_name ||= :"#{action_name}_resource#{collection ? 's' : ''}"

      describe "##{action_name}" do
        let(:resource) do
          defined?(super()) ? super() : controller.send(:resource)
        end
        let(:action) { action_name }

        before(:example) do
          allow(controller)
            .to receive(:action_name)
            .and_return(action.to_s)
        end

        it { expect(controller).to respond_to(action_name).with(0).arguments }

        include_examples 'should dispatch a response for',
          operation_name,
          status: status
      end
    end

    shared_examples 'should dispatch a response for' \
    do |operation_name, status: nil|
      shared_examples 'should delegate to the responder' do
        let(:resources)     { {} }
        let(:responder)     { instance_double(Responders::Base, call: nil) }
        let(operation_name) { instance_double(Cuprum::Operation) }
        let(:expected_result) do
          value =
            if defined?(expected_value)
              expected_value
            else
              result.value || {}
            end

          Cuprum::Result.new(
            error:  result.error,
            status: result.status,
            value:  value
          )
        end
        let(:expected_options) do
          {
            action: action,
            status: status
          }
        end

        before(:example) do
          allow(controller).to receive(:resources).and_return(resources)

          allow(controller).to receive(:responder).and_return(responder)

          allow(controller).to receive(operation_name).and_return(result)
        end

        it 'should delegate to the responder' do
          controller.send(action)

          expect(responder)
            .to have_received(:call)
            .with(expected_result, expected_options)
        end

        context 'when the controller has resources' do
          let(:resources) do
            {
              'interviews' => Array.new(3) { Spec::Interview.new },
              'recruiter'  => Spec::Recruiter.new
            }
          end
          let(:expected_value) do
            value = defined?(super()) ? super() : (result.value || {})

            resources.merge(value)
          end

          example_class 'Spec::Interview'

          example_class 'Spec::Recruiter'

          it 'should delegate to the responder' do
            controller.send(action)

            expect(responder)
              .to have_received(:call)
              .with(expected_result, expected_options)
          end
        end
      end

      context 'when the operation returns a result with an error' do
        let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result) { Cuprum::Result.new(error: error) }

        include_examples 'should delegate to the responder'
      end

      context 'when the operation returns a result with an error and a value' do
        let(:value)  { (resource.record_class || Object).new }
        let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result) { Cuprum::Result.new(error: error, value: value) }
        let(:expected_value) do
          { resource.singular_name => value }
        end

        include_examples 'should delegate to the responder'
      end

      context 'when the operation returns a result with a value' do
        let(:value)  { (resource.record_class || Object).new }
        let(:result) { Cuprum::Result.new(value: value) }
        let(:expected_value) do
          { resource.singular_name => value }
        end

        include_examples 'should delegate to the responder'
      end

      context 'when the operation returns a result with a value hash' do
        let(:value) do
          { resource.singular_name => (resource.record_class || Object).new }
        end
        let(:result) { Cuprum::Result.new(value: value) }

        include_examples 'should delegate to the responder'
      end
    end
  end
end
