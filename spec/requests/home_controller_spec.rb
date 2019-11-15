# frozen_string_literal: true

require 'rails_helper'

require 'support/examples/controller_examples'

RSpec.describe HomeController, type: :request do
  include Spec::Support::Examples::ControllerExamples

  include_context 'with valid credentials for HTTP basic authorization'

  let(:headers) { {} }
  let(:params)  { {} }

  describe 'GET /' do
    def call_action
      get '/', headers: headers, params: params
    end

    include_examples 'should require HTTP basic authorization'

    it 'should respond with 200 OK', :aggregate_failures do
      call_action

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to be == 'text/html; charset=utf-8'
    end

    it 'should render the home view' do
      call_action

      expect(response).to render_template(:index)
    end
  end
end
