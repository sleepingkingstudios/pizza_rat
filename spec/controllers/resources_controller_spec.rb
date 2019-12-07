# frozen_string_literal: true

require 'rails_helper'

require 'operations/records/factory'

RSpec.describe ResourcesController do
  subject(:controller) { described_class.new }

  shared_context 'when the controller defines a resource' do
    let(:resource) { Resource.new(Job) }
    let(:permitted_attributes) do
      %w[company_name source time_period title]
    end

    before(:example) do
      allow(controller) # rubocop:disable RSpec/SubjectStub
        .to receive(:permitted_attributes)
        .and_return(permitted_attributes)

      allow(controller) # rubocop:disable RSpec/SubjectStub
        .to receive(:resource)
        .and_return(resource)
    end
  end

  shared_context 'with a params hash' do
    let(:params) { {} }

    before(:example) do
      # rubocop:disable RSpec/SubjectStub
      allow(controller).to receive(:params) do
        ActionController::Parameters.new(params)
      end
      # rubocop:enable RSpec/SubjectStub
    end
  end

  shared_examples 'should define action' \
  do |action_name, collection: false, status: nil|
    operation_name ||= :"#{action_name}_resource#{collection ? 's' : ''}"

    describe "##{action_name}" do
      include_context 'when the controller defines a resource'

      let(:action) { action_name }

      before(:example) do
        allow(controller) # rubocop:disable RSpec/SubjectStub
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
        value = defined?(expected_value) ? expected_value : (result.value || {})

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
        # rubocop:disable RSpec/SubjectStub
        allow(controller).to receive(:resources).and_return(resources)

        allow(controller).to receive(:responder).and_return(responder)

        allow(controller).to receive(operation_name).and_return(result)
        # rubocop:enable RSpec/SubjectStub
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
      let(:value)  { resource.record_class.new }
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result) { Cuprum::Result.new(error: error, value: value) }
      let(:expected_value) do
        { 'job' => value }
      end

      include_examples 'should delegate to the responder'
    end

    context 'when the operation returns a result with a value' do
      let(:value)  { resource.record_class.new }
      let(:result) { Cuprum::Result.new(value: value) }
      let(:expected_value) do
        { 'job' => value }
      end

      include_examples 'should delegate to the responder'
    end

    context 'when the operation returns a result with a value hash' do
      let(:value)  { { 'job' => resource.record_class.new } }
      let(:result) { Cuprum::Result.new(value: value) }

      include_examples 'should delegate to the responder'
    end
  end

  let(:resource_params) do
    {
      'company_name' => 'Weyland-Yutani',
      'source'       => '20th Century Fox',
      'time_period'  => '2020-01',
      'title'        => 'Freighter Crew'
    }
  end

  include_examples 'should define action', :create, status: :created

  include_examples 'should define action', :destroy

  include_examples 'should define action', :edit

  include_examples 'should define action', :index, collection: true

  include_examples 'should define action', :new

  include_examples 'should define action', :show

  include_examples 'should define action', :update

  describe '#create_resource' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:params) { { resource.singular_name => resource_params } }

    def a_job_with_expected_attributes
      an_instance_of(Job)
        .and(satisfy { |job| job.attributes >= resource_params })
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:create_resource, true)
        .with(0).arguments
    end

    it 'should call step :require_resource_params' do
      expect { controller.send(:create_resource) }
        .to call_command_step(controller, :require_resource_params)
        .with_arguments(no_args)
    end

    it 'should call step operation_factory::Create' do
      expect { controller.send(:create_resource) }
        .to call_command_step(resource.operation_factory::Create)
        .with_arguments(resource_params)
    end

    it 'should return an instance of the resource' do
      expect(controller.send(:create_resource))
        .to be_a_passing_result
        .with_value(a_job_with_expected_attributes)
    end
  end

  describe '#default_order' do
    it 'should define the private method' do
      expect(controller)
        .to respond_to(:default_order, true)
        .with(0).arguments
    end

    it { expect(controller.send :default_order).to be == {} }
  end

  describe '#destroy_resource' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:destroy_resource, true)
        .with(0).arguments
    end

    it 'should call step operation_factory::FindOne' do
      expect { controller.send(:destroy_resource) }
        .to call_command_step(resource.operation_factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should call step operation_factory::Destroy' do
      expect { controller.send(:destroy_resource) }
        .to call_command_step(resource.operation_factory::Destroy)
        .with_arguments(job)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:destroy_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#edit_resource' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:edit_resource, true)
        .with(0).arguments
    end

    it 'should call step operation_factory::FindOne' do
      expect { controller.send(:edit_resource) }
        .to call_command_step(resource.operation_factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:edit_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#failure' do
    let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:failure, true)
        .with(1).argument
    end

    it 'should return a failing result' do
      expect(controller.send :failure, error)
        .to be_a_failing_result.with_error(error)
    end
  end

  describe '#index_order' do
    include_context 'with a params hash'

    let(:default_order) { 'created_at:asc' }

    before(:example) do
      allow(controller) # rubocop:disable RSpec/SubjectStub
        .to receive(:default_order)
        .and_return(default_order)
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:index_order, true)
        .with(0).arguments
    end

    it { expect(controller.send :index_order).to be default_order }

    context 'when params[:order] is set' do
      let(:order)  { 'name:asc' }
      let(:params) { super().merge(order: order) }

      it { expect(controller.send :index_order).to be == order }
    end
  end

  describe '#index_params' do
    include_context 'with a params hash'

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:resource_params, true)
        .with(0).arguments
    end

    it { expect(controller.send :index_params).to be == {} }

    context 'when params[:order] is set' do
      let(:order)  { 'name:asc' }
      let(:params) { super().merge(order: order) }

      it { expect(controller.send :index_params).to be == { 'order' => order } }
    end
  end

  describe '#index_resources' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:params) { {} }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:index_resources, true)
        .with(0).arguments
    end

    it 'should call step :normalize_sort' do
      expect { controller.send(:index_resources) }
        .to call_command_step(controller, :normalize_sort)
        .with_arguments({})
    end

    it 'should call step operation_factory::FindMatching' do
      expect { controller.send(:index_resources) }
        .to call_command_step(resource.operation_factory::FindMatching)
        .with_arguments(order: {})
    end

    it 'should return the matching resource instances' do
      expect(controller.send(:index_resources))
        .to be_a_passing_result
        .with_value([])
    end

    context 'when params[:order] is set' do
      let(:order)  { 'company_name:asc' }
      let(:params) { super().merge(order: order) }

      it 'should call step :normalize_sort' do
        expect { controller.send(:index_resources) }
          .to call_command_step(controller, :normalize_sort)
          .with_arguments(order)
      end

      it 'should call step operation_factory::FindMatching' do
        expect { controller.send(:index_resources) }
          .to call_command_step(resource.operation_factory::FindMatching)
          .with_arguments(order: { 'company_name' => 'asc' })
      end
    end

    context 'when there are many jobs' do
      let!(:jobs) { Array.new(3) { FactoryBot.create(:job) } }

      it 'should return the matching resource instances' do
        expect(controller.send(:index_resources))
          .to be_a_passing_result
          .with_value(contain_exactly(*jobs))
      end

      context 'when params[:order] is set' do
        let(:order)  { 'company_name:asc' }
        let(:params) { super().merge(order: order) }

        it 'should call step :normalize_sort' do
          expect { controller.send(:index_resources) }
            .to call_command_step(controller, :normalize_sort)
            .with_arguments(order)
        end

        it 'should call step operation_factory::FindMatching' do
          expect { controller.send(:index_resources) }
            .to call_command_step(resource.operation_factory::FindMatching)
            .with_arguments(order: { 'company_name' => 'asc' })
        end

        it 'should return the matching resource instances' do
          expect(controller.send(:index_resources))
            .to be_a_passing_result
            .with_value(jobs.sort_by(&:company_name))
        end
      end
    end
  end

  describe '#new_resource' do
    include_context 'when the controller defines a resource'

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:new_resource, true)
        .with(0).arguments
    end

    it 'should call step operation_factory::Build' do
      expect { controller.send(:new_resource) }
        .to call_command_step(resource.operation_factory::Build)
        .with_arguments(no_args)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:new_resource))
        .to be_a_passing_result
        .with_value(an_instance_of(Job))
    end
  end

  describe '#normalize_response_value' do
    it 'should define the private method' do
      expect(controller)
        .to respond_to(:normalize_response_value, true)
        .with(1).argument
    end

    describe 'with nil' do
      it { expect(controller.send :normalize_response_value, nil).to be == {} }
    end

    describe 'with an Array' do
      include_context 'when the controller defines a resource'

      let(:value)    { Array.new(3) { FactoryBot.build(:job) } }
      let(:expected) { { resource.plural_name => value } }

      it 'should wrap the Array in a Hash' do
        expect(controller.send :normalize_response_value, value)
          .to be == expected
      end
    end

    describe 'with a Hash' do
      let(:value) { { 'key' => 'value' } }

      it 'should return the Hash' do
        expect(controller.send :normalize_response_value, value).to be == value
      end
    end

    describe 'with an object' do
      include_context 'when the controller defines a resource'

      let(:value)    { FactoryBot.build(:job) }
      let(:expected) { { resource.singular_name => value } }

      it 'should wrap the object in a Hash' do
        expect(controller.send :normalize_response_value, value)
          .to be == expected
      end
    end
  end

  describe '#normalize_sort' do
    def normalize(value)
      controller.send :normalize_sort, value
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:normalize_sort, true)
        .with(1).argument
    end

    describe 'with nil' do
      it { expect(normalize nil).to be == {} }
    end

    describe 'with an object' do
      let(:object) { Object.new.freeze }
      let(:expected_error) do
        Errors::InvalidParameters.new(errors: [['order', 'is invalid']])
      end

      it 'should return a failing result' do
        expect(normalize object)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an empty Hash' do
      it { expect(normalize({})).to be == {} }
    end

    describe 'with a Hash with values' do
      let(:hash) { { level: :asc, name: :asc } }

      it { expect(normalize hash).to be == hash }
    end

    describe 'with an empty String' do
      it { expect(normalize '').to be == {} }
    end

    describe 'with a String with a value of :asc' do
      it { expect(normalize 'name:asc').to be == { 'name' => 'asc' } }
    end

    describe 'with a String with a value of :ascending' do
      it { expect(normalize 'name:ascending').to be == { 'name' => 'asc' } }
    end

    describe 'with a String with multiple tuples' do
      it 'should convert the string to a hash' do
        expect(normalize 'level:desc::name:asc')
          .to be == { 'level' => 'desc', 'name' => 'asc' }
      end
    end
  end

  describe '#operation_factory' do
    include_context 'when the controller defines a resource'

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:operation_factory, true)
        .with(0).arguments
    end

    it 'should delegate to the resource' do
      expect(controller.send :operation_factory)
        .to be resource.operation_factory
    end
  end

  describe '#permitted_attributes' do
    it 'should define the private method' do
      expect(controller)
        .to respond_to(:permitted_attributes, true)
        .with(0).arguments
    end

    it { expect(controller.send :permitted_attributes).to be == [] }
  end

  describe '#require_resource_params' do
    include_context 'with a params hash'

    let(:expected_error) do
      Cuprum::Error.new(
        message: 'No attributes are permitted for the current action'
      )
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:require_resource_params, true)
        .with(0).arguments
    end

    it 'should return a failing result' do
      expect(controller.send :require_resource_params)
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_context 'when the controller defines a resource' do
      let(:expected_error) do
        Errors::InvalidParameters.new(
          errors: [['job', "can't be blank"]]
        )
      end

      it 'should return a failing result' do
        expect(controller.send :require_resource_params)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  describe '#resource_id' do
    include_context 'with a params hash'

    it 'should define the private method' do
      expect(controller).to respond_to(:resource_id, true).with(0).arguments
    end

    it { expect(controller.send :resource_id).to be nil }

    context 'when params[:id] is set' do
      let(:id)     { '0' }
      let(:params) { super().merge('id' => id) }

      it { expect(controller.send :resource_id).to be == id.to_i }
    end
  end

  describe '#resource_params' do
    include_context 'with a params hash'

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:resource_params, true)
        .with(0).arguments
    end

    wrap_context 'when the controller defines a resource' do
      let(:params) { super().merge(resource.singular_name => resource_params) }

      it { expect(controller.send :resource_params).to be == resource_params }
    end
  end

  describe '#resources' do
    include_examples 'should have private reader', :resources, {}
  end

  describe '#responder' do
    include_context 'when the controller defines a resource'

    let(:responder) { controller.send :responder }

    it 'should define the private method' do
      expect(controller).to respond_to(:responder, true).with(0).arguments
    end

    it { expect(responder).to be_a Responders::Html }

    it { expect(responder.controller).to be controller }

    it { expect(responder.resource).to be resource }
  end

  describe '#show_resource' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:show_resource, true)
        .with(0).arguments
    end

    it 'should call step operation_factory::FindOne' do
      expect { controller.send(:show_resource) }
        .to call_command_step(resource.operation_factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:show_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#success' do
    let(:value) { 'result value' }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:success, true)
        .with(1).argument
    end

    it 'should return a passing result' do
      expect(controller.send :success, value)
        .to be_a_passing_result.with_value(value)
    end
  end

  describe '#update_resource' do
    include_context 'when the controller defines a resource'
    include_context 'with a params hash'

    let(:job) { FactoryBot.create(:job) }
    let(:params) do
      { 'id' => job.id, resource.singular_name => resource_params }
    end

    def the_job_with_updated_attributes
      an_instance_of(Job)
        .and(satisfy { |obj| obj.id == job.id })
        .and(satisfy { |obj| obj.attributes >= resource_params })
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:update_resource, true)
        .with(0).arguments
    end

    it 'should call step :require_resource_params' do
      expect { controller.send(:update_resource) }
        .to call_command_step(controller, :require_resource_params)
        .with_arguments(no_args)
    end

    it 'should call step operation_factory::FindOne' do
      expect { controller.send(:update_resource) }
        .to call_command_step(resource.operation_factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should call step operation_factory::Update' do
      expect { controller.send(:update_resource) }
        .to call_command_step(resource.operation_factory::Update)
        .with_arguments(job, resource_params)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:update_resource))
        .to be_a_passing_result
        .with_value(the_job_with_updated_attributes)
    end
  end
end
