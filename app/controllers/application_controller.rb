# frozen_string_literal: true

# Abstract base class for controllers.
class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name:     ENV.fetch(
      'HTTP_BASIC_AUTH_USERNAME',
      Rails.application.credentials.http_basic_auth_username
    ),
    password: ENV.fetch(
      'HTTP_BASIC_AUTH_PASSWORD',
      Rails.application.credentials.http_basic_auth_password
    )
  )
end
