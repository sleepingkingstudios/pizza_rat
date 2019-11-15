# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  let(:controller) { 'home' }

  describe 'GET /' do
    it 'should route to HomeController#index' do
      expect(get: '/').to route_to(
        controller: controller,
        action:     'index'
      )
    end
  end
end
