# frozen_string_literal: true

require 'rails_helper'

require 'responders/base'

RSpec.describe Responders::Base do
  subject(:responder) { described_class.new(controller) }

  let(:controller) { instance_double(ApplicationController) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:resource)
    end
  end

  describe '#call' do
    before(:example) { allow(controller).to receive(:head) }

    it 'should define the method' do
      expect(responder)
        .to respond_to(:call)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with a failing result with error: FailedValidation' do
      let(:record) { Job.new }
      let(:error)  { Errors::FailedValidation.new(record: record) }
      let(:result) { Cuprum::Result.new(error: error) }

      it 'should respond with Head 422 Unprocessable Entity' do
        responder.call(result)

        expect(controller).to have_received(:head).with(:unprocessable_entity)
      end
    end

    describe 'with a failing result with error: InvalidParameters' do
      let(:error)  { Errors::InvalidParameters.new(errors: []) }
      let(:result) { Cuprum::Result.new(error: error) }

      it 'should respond with Head 400 Bad Request' do
        responder.call(result)

        expect(controller).to have_received(:head).with(:bad_request)
      end
    end

    describe 'with a failing result with error: NotFound' do
      let(:record_class) { Job }
      let(:attributes)   { { id: 0 } }
      let(:error) do
        Errors::NotFound.new(attributes: attributes, record_class: record_class)
      end
      let(:result)       { Cuprum::Result.new(error: error) }

      it 'should respond with Head 404 Not Found' do
        responder.call(result)

        expect(controller).to have_received(:head).with(:not_found)
      end
    end

    describe 'with a failing result with error: unknown error' do
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result) { Cuprum::Result.new(error: error) }

      it 'should respond with Head 500 Internal Server Error' do
        responder.call(result)

        expect(controller).to have_received(:head).with(:internal_server_error)
      end
    end

    describe 'with a failing result and status: value' do
      let(:error)   { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result)  { Cuprum::Result.new(error: error) }
      let(:options) { { status: :service_unavailable } }

      it 'should respond with Head 500 Internal Server Error' do
        responder.call(result, options)

        expect(controller).to have_received(:head).with(:internal_server_error)
      end

      it 'should set the options' do
        responder.call(result, options)

        expect(responder.options).to be == options
      end
    end

    describe 'with a passing result' do
      let(:result) { Cuprum::Result.new(status: :success) }

      it 'should respond with Head 200 OK' do
        responder.call(result)

        expect(controller).to have_received(:head).with(:ok)
      end
    end

    describe 'with a passing result and status: value' do
      let(:result)  { Cuprum::Result.new(status: :success) }
      let(:options) { { status: :created } }

      it 'should respond with Head 201 Created' do
        responder.call(result, options)

        expect(controller).to have_received(:head).with(:created)
      end

      it 'should set the options' do
        responder.call(result, options)

        expect(responder.options).to be == options
      end
    end
  end

  describe '#controller' do
    include_examples 'should define reader', :controller, -> { controller }
  end

  describe '#head' do
    let(:status)  { 418 }
    let(:options) { { message: "I'm a Teapot" } }

    before(:example) do
      allow(controller).to receive(:head)
    end

    it { expect(responder).to respond_to(:head).with(1..2).arguments }

    it 'should delegate to the controller' do
      responder.head(status, options)

      expect(controller).to have_received(:head).with(status, options)
    end
  end

  describe '#options' do
    include_examples 'should define reader', :options, {}
  end

  describe '#redirect_to' do
    let(:path) { '/path/to/resource' }

    before(:example) do
      allow(controller).to receive(:redirect_to)
    end

    it { expect(responder).to respond_to(:redirect_to).with(1..2).arguments }

    it 'should delegate to the controller' do
      responder.redirect_to(path)

      expect(controller).to have_received(:redirect_to).with(path)
    end

    describe 'with options' do
      let(:options) { { status: 301 } }

      it 'should delegate to the controller' do
        responder.redirect_to(path, options)

        expect(controller).to have_received(:redirect_to).with(path, options)
      end
    end
  end

  describe '#render' do
    let(:options) { { text: "I'm a Teapot" } }

    before(:example) do
      allow(controller).to receive(:render)
    end

    it { expect(responder).to respond_to(:render).with(1).argument }

    it 'should delegate to the controller' do
      responder.render(options)

      expect(controller).to have_received(:render).with(options)
    end
  end

  describe '#resource' do
    let(:resource) { responder.resource }

    include_examples 'should define reader', :resource

    it { expect(responder.resource).to be_a Resource }

    it { expect(resource.record_class).to be nil }

    it { expect(resource.name).to be 'resource' }

    context 'when initialized with a resource' do
      subject(:responder) do
        described_class.new(controller, resource: resource)
      end

      let(:resource) { Resource.new(Job, name: 'active_job') }

      it { expect(responder.resource).to be resource }
    end
  end
end
