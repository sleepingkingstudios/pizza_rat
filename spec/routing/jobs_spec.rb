# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  let(:controller) { 'jobs' }
  let(:job_id)     { '0' }

  describe 'GET /jobs' do
    it 'should route to JobsController#index' do
      expect(get: '/jobs').to route_to(
        controller: controller,
        action:     'index'
      )
    end
  end

  describe 'GET /jobs/new' do
    it 'should route to JobsController#new' do
      expect(get: '/jobs/new').to route_to(
        controller: controller,
        action:     'new'
      )
    end
  end

  describe 'POST /jobs' do
    it 'should route to JobsController#create' do
      expect(post: '/jobs').to route_to(
        controller: controller,
        action:     'create'
      )
    end
  end

  describe 'GET /jobs/:id' do
    it 'should route to JobsController#show' do
      expect(get: "/jobs/#{job_id}").to route_to(
        controller: controller,
        action:     'show',
        id:         job_id
      )
    end
  end

  describe 'GET /jobs/:id/edit' do
    it 'should route to JobsController#edit' do
      expect(get: "/jobs/#{job_id}/edit").to route_to(
        controller: controller,
        action:     'edit',
        id:         job_id
      )
    end
  end

  describe 'PATCH /jobs/:id' do
    it 'should route to JobsController#update' do
      expect(patch: "/jobs/#{job_id}").to route_to(
        controller: controller,
        action:     'update',
        id:         job_id
      )
    end
  end

  describe 'PUT /jobs/:id' do
    it 'should route to JobsController#update' do
      expect(put: "/jobs/#{job_id}").to route_to(
        controller: controller,
        action:     'update',
        id:         job_id
      )
    end
  end

  describe 'DELETE /jobs/:id' do
    it 'should route to JobsController#destroy' do
      expect(delete: "/jobs/#{job_id}").to route_to(
        controller: controller,
        action:     'destroy',
        id:         job_id
      )
    end
  end
end
