# frozen_string_literal: true

require 'rails_helper'

require 'support/examples/resources_controller_examples'

RSpec.describe JobsController, type: :controller do
  include Spec::Support::Examples::ResourcesControllerExamples

  subject(:controller) { described_class.new }

  let(:resource) { controller.send :resource }
  let(:resource_params) do
    {
      'company_name'   => 'Weyland-Yutani',
      'job_type'       => Job::JobTypes::FULL_TIME,
      'source'         => '20th Century Fox',
      'time_period_id' => time_period.id,
      'title'          => 'Freighter Crew'
    }
  end
  let(:time_period) { FactoryBot.create(:time_period) }

  include_examples 'should define action', :create, status: :created

  include_examples 'should define action', :destroy

  include_examples 'should define action', :edit

  include_examples 'should define action', :index, collection: true

  include_examples 'should define action', :new

  include_examples 'should define action', :show

  include_examples 'should define action', :update

  describe '#create_resource' do
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
        .to call_command_step(Job::Factory::Create)
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

    it 'should set the default order' do
      expect(controller.send :default_order).to be == { company_name: :asc }
    end
  end

  describe '#destroy_resource' do
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job, :with_time_period) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:destroy_resource, true)
        .with(0).arguments
    end

    it 'should call step operation_factory::FindOne' do
      expect { controller.send(:destroy_resource) }
        .to call_command_step(Job::Factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should call step operation_factory::Destroy' do
      expect { controller.send(:destroy_resource) }
        .to call_command_step(Job::Factory::Destroy)
        .with_arguments(job)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:destroy_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#edit_resource' do
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job, :with_time_period) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:edit_resource, true)
        .with(0).arguments
    end

    it 'should call step Job::Factory::FindOne' do
      expect { controller.send(:edit_resource) }
        .to call_command_step(Job::Factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:edit_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#index_resources' do
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
        .with_arguments(controller.send :default_order)
    end

    it 'should call step Job::Factory::FindMatching' do
      expect { controller.send(:index_resources) }
        .to call_command_step(Job::Factory::FindMatching)
        .with_arguments(order: controller.send(:default_order))
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

      it 'should call step Job::Factory::FindMatching' do
        expect { controller.send(:index_resources) }
          .to call_command_step(Job::Factory::FindMatching)
          .with_arguments(order: { 'company_name' => 'asc' })
      end
    end

    context 'when there are many jobs' do
      let!(:jobs) do
        Array.new(3) { FactoryBot.create(:job, :with_time_period) }
      end

      it 'should return the matching resource instances' do
        expect(controller.send(:index_resources))
          .to be_a_passing_result
          .with_value(contain_exactly(*jobs))
      end

      context 'when params[:order] is set' do
        let(:order)  { 'title:asc' }
        let(:params) { super().merge(order: order) }

        it 'should call step :normalize_sort' do
          expect { controller.send(:index_resources) }
            .to call_command_step(controller, :normalize_sort)
            .with_arguments(order)
        end

        it 'should call step Job::Factory::FindMatching' do
          expect { controller.send(:index_resources) }
            .to call_command_step(Job::Factory::FindMatching)
            .with_arguments(order: { 'title' => 'asc' })
        end

        it 'should return the matching resource instances' do
          expect(controller.send(:index_resources))
            .to be_a_passing_result
            .with_value(jobs.sort_by(&:title))
        end
      end
    end
  end

  describe '#new_resource' do
    it 'should define the private method' do
      expect(controller)
        .to respond_to(:new_resource, true)
        .with(0).arguments
    end

    it 'should call step Job::Factory::Build' do
      expect { controller.send(:new_resource) }
        .to call_command_step(Job::Factory::Build)
        .with_arguments(no_args)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:new_resource))
        .to be_a_passing_result
        .with_value(an_instance_of(Job))
    end
  end

  describe '#permitted_attributes' do
    let(:expected) do
      %i[
        action_required
        application_active
        application_status
        company_name
        data
        job_type
        notes
        recruiter_agency
        recruiter_name
        source
        source_data
        time_period_id
        title
      ]
    end

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:permitted_attributes, true)
        .with(0).arguments
    end

    it { expect(controller.send :permitted_attributes).to be == expected }
  end

  describe '#resource' do
    it 'should define the private method' do
      expect(controller).to respond_to(:resource, true).with(0).arguments
    end

    it { expect(controller.send :resource).to be_a Resource }

    it { expect(controller.send(:resource).name).to be == 'job' }

    it { expect(controller.send(:resource).record_class).to be Job }
  end

  describe '#show_resource' do
    include_context 'with a params hash'

    let(:job)    { FactoryBot.create(:job, :with_time_period) }
    let(:params) { { 'id' => job.id } }

    it 'should define the private method' do
      expect(controller)
        .to respond_to(:show_resource, true)
        .with(0).arguments
    end

    it 'should call step Jobs::Factory::FindOne' do
      expect { controller.send(:show_resource) }
        .to call_command_step(Job::Factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should return the job' do
      expect(controller.send(:show_resource))
        .to be_a_passing_result
        .with_value(job)
    end
  end

  describe '#update_resource' do
    include_context 'with a params hash'

    let(:job) { FactoryBot.create(:job, :with_time_period) }
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
        .to call_command_step(Job::Factory::FindOne)
        .with_arguments(job.id)
    end

    it 'should call step operation_factory::Update' do
      expect { controller.send(:update_resource) }
        .to call_command_step(Job::Factory::Update)
        .with_arguments(job, resource_params)
    end

    it 'should return the instance of the resource' do
      expect(controller.send(:update_resource))
        .to be_a_passing_result
        .with_value(the_job_with_updated_attributes)
    end
  end
end
