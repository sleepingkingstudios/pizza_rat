# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module ControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with valid credentials for HTTP basic authorization' do
      let(:username) { 'user@example.com' }
      let(:password) { 'password' }
      let(:authorization) do
        ActionController::HttpAuthentication::Basic
          .encode_credentials(username, password)
      end

      before(:example) { headers['HTTP_AUTHORIZATION'] = authorization }
    end

    shared_examples 'should require HTTP basic authorization' do
      describe 'with a missing authorization header' do
        before(:example) { headers.delete 'HTTP_AUTHORIZATION' }

        it 'should respond with 401 Unauthorized', :aggregate_failures do
          call_action

          expect(response).to have_http_status(:unauthorized)
          expect(response.content_type).to be == 'text/html; charset=utf-8'
        end
      end

      describe 'with an invalid password' do
        let(:password) { '12345' }

        it 'should respond with 401 Unauthorized', :aggregate_failures do
          call_action

          expect(response).to have_http_status(:unauthorized)
          expect(response.content_type).to be == 'text/html; charset=utf-8'
        end
      end

      describe 'with an invalid username' do
        let(:username) { 'attacker@example.com' }

        it 'should respond with 401 Unauthorized', :aggregate_failures do
          call_action

          expect(response).to have_http_status(:unauthorized)
          expect(response.content_type).to be == 'text/html; charset=utf-8'
        end
      end
    end
  end
end
