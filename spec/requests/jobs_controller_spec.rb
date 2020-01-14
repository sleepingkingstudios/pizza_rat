# frozen_string_literal: true

require 'rails_helper'

require 'fixtures/builder'

require 'support/examples/controller_examples'

RSpec.describe JobsController, type: :request do
  include Spec::Support::Examples::ControllerExamples

  shared_context 'when there are many time periods' do
    let(:time_periods) { Fixtures.build(TimePeriod) }

    before(:each) { time_periods.each(&:save!) }
  end

  shared_context 'when there are many jobs' do
    include_context 'when there are many time periods'

    let(:jobs) { Fixtures.build(Job, count: 3) }

    before(:each) { jobs.each(&:save!) }
  end

  shared_examples 'should require a valid job id' do
    describe 'with an invalid job id' do
      let(:job_id) { (Job.last&.id || 0) + 1 }

      it 'should respond with 302 Found', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:found)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      it 'should redirect to the jobs index page' do
        call_action

        expect(response).to redirect_to(jobs_path)
      end
    end
  end

  include_context 'with valid credentials for HTTP basic authorization'

  let(:headers) { {} }
  let(:params)  { {} }

  describe 'GET /jobs' do
    def call_action
      get '/jobs', headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    it 'should respond with 200 OK', :aggregate_failures do
      call_action

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to be == 'text/html; charset=utf-8'
    end

    it 'should render the jobs index view', :aggregate_failures do
      call_action

      expect(response).to render_template('jobs/index')
      expect(response.body).to include 'Jobs'
      expect(response.body).to include 'There are no jobs defined.'
    end

    wrap_context 'when there are many jobs' do
      include_context 'when there are many jobs'

      # rubocop:disable RSpec/ExampleLength
      it 'should render the jobs index view', :aggregate_failures do
        call_action

        expect(response).to render_template(:index)

        jobs.each do |job|
          expect(response.body).to include job.company_name
          expect(response.body).to include job.title
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'GET /jobs/new' do
    def call_action
      get '/jobs/new', headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    it 'should respond with 200 OK', :aggregate_failures do
      call_action

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to be == 'text/html; charset=utf-8'
    end

    it 'should render the new job view', :aggregate_failures do
      call_action

      expect(response).to render_template('jobs/new')
      expect(response.body).to include 'New Job'
      expect(response.body).to include 'Create Job'
    end
  end

  describe 'POST /jobs' do
    include_context 'when there are many time periods'

    def call_action
      post '/jobs', headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    describe 'with invalid attributes' do
      let(:job_attributes) do
        {
          'company_name'   => nil,
          'source'         => '20th Century Fox',
          'time_period_id' => time_periods.first.id,
          'title'          => 'Freighter Crew'
        }
      end
      let(:params) { { 'job' => job_attributes } }

      it 'should respond with 422 Unprocessable Entity', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should render the new job view', :aggregate_failures do
        call_action

        expect(response).to render_template('jobs/new')
        expect(response.body).to include 'New Job'
        expect(response.body).to include 'Create Job'
        expect(response.body).to include 'Unable to create Job'
        expect(response.body).to include 'Company name can&#39;t be blank'
      end
      # rubocop:enable RSpec/ExampleLength

      it 'should not create a job', :aggregate_failures do
        expect { call_action }.not_to change(Job, :count)

        expect(Job.where(job_attributes).exists?).to be false
      end
    end

    describe 'with valid attributes' do
      let(:job_attributes) do
        {
          'company_name'   => 'Weyland-Yutani',
          'source'         => '20th Century Fox',
          'time_period_id' => time_periods.first.id,
          'title'          => 'Freighter Crew'
        }
      end
      let(:job)    { Job.where(job_attributes).last }
      let(:params) { { 'job' => job_attributes } }

      it 'should respond with 302 Found', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:found)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      it 'should redirect to the created job show page' do
        call_action

        expect(response).to redirect_to(job_path(job))
      end

      it 'should create a job', :aggregate_failures do
        expect { call_action }.to change(Job, :count).by(1)

        expect(Job.where(job_attributes).exists?).to be true
      end
    end
  end

  describe 'GET /jobs/:id' do
    let(:job_id) { 0 }

    def call_action
      get "/jobs/#{job_id}", headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    include_examples 'should require a valid job id'

    describe 'with a valid job id' do
      let(:job)    { FactoryBot.build(:job, :with_time_period) }
      let(:job_id) { job.id }

      before(:example) { job.save! }

      it 'should respond with 200 OK', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      it 'should render the show job view', :aggregate_failures do
        call_action

        expect(response).to render_template(:show)
        expect(response.body).to include job.company_name
        expect(response.body).to include job.title
      end
    end
  end

  describe 'GET /jobs/:id/edit' do
    let(:job_id) { 0 }

    def call_action
      get "/jobs/#{job_id}/edit", headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    include_examples 'should require a valid job id'

    describe 'with a valid job id' do
      let(:job)    { FactoryBot.build(:job, :with_time_period) }
      let(:job_id) { job.id }

      before(:example) { job.save! }

      it 'should respond with 200 OK', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should render the edit job view', :aggregate_failures do
        call_action

        expect(response).to render_template(:edit)
        expect(response.body).to include job.company_name
        expect(response.body).to include job.title
        expect(response.body).to include 'Edit Job'
        expect(response.body).to include 'Update Job'
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'PATCH /jobs/:id' do
    let(:job_id) { 0 }

    def call_action
      patch "/jobs/#{job_id}", headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    include_examples 'should require a valid job id'

    describe 'with invalid attributes' do
      let(:job_attributes) do
        { 'company_name' => nil }
      end
      let(:job)    { FactoryBot.build(:job, :with_time_period) }
      let(:job_id) { job.id }
      let(:params) { { 'job' => job_attributes } }

      before(:example) { job.save! }

      it 'should respond with 422 Unprocessable Entity', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should render the edit job view', :aggregate_failures do
        call_action

        expect(response).to render_template('jobs/edit')
        expect(response.body).to include 'Edit Job'
        expect(response.body).to include 'Update Job'
        expect(response.body).to include 'Unable to update Job'
        expect(response.body).to include 'Company name can&#39;t be blank'
      end
      # rubocop:enable RSpec/ExampleLength

      it 'should not update the job' do
        expect { call_action }.not_to(change { job.reload.attributes })
      end
    end

    describe 'with valid attributes' do
      let(:job_attributes) do
        { 'company_name' => 'Weyland-Yutani' }
      end
      let(:job)    { FactoryBot.build(:job, :with_time_period) }
      let(:job_id) { job.id }
      let(:params) { { 'job' => job_attributes } }

      before(:example) { job.save! }

      it 'should respond with 302 Found', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:found)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      it 'should redirect to the updated job show page' do
        call_action

        expect(response).to redirect_to(job_path(job))
      end

      it 'should update the job' do
        expect { call_action }
          .to change { job.reload.attributes }
          .to be >= job_attributes
      end
    end
  end

  describe 'DELETE /jobs/:id' do
    let(:job_id) { 0 }

    def call_action
      delete "/jobs/#{job_id}", headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    include_examples 'should require a valid job id'

    describe 'with a valid job id' do
      let(:job)    { FactoryBot.build(:job, :with_time_period) }
      let(:job_id) { job.id }

      before(:example) { job.save! }

      it 'should respond with 302 Found', :aggregate_failures do
        call_action

        expect(response).to have_http_status(:found)
        expect(response.content_type).to be == 'text/html; charset=utf-8'
      end

      it 'should redirect to the jobs index page' do
        call_action

        expect(response).to redirect_to(jobs_path)
      end

      it 'should delete the job', :aggregate_failures do
        expect { call_action }.to change(Job, :count).by(-1)

        expect(Job.where(id: job.id).exists?).to be false
      end
    end
  end
end
