# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.1'

gem 'bcrypt', '~> 3.1.7'
gem 'pg', '>= 0.18', '< 2.0' # Use postgresql as the database for Active Record

# Use Puma as the app server
gem 'puma', '~> 4.1'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # Run commands to aggregate CI steps, generate templated files, etc.
  gem 'sleeping_king_studios-tasks', '~> 0.2'
end

group :test do
  gem 'rspec', '~> 3.9'
  gem 'rspec-rails', '~> 3.9'
  gem 'rspec-sleeping_king_studios', '~> 2.5', '>= 2.5.1'

  gem 'rubocop', '~> 0.76.0'
  gem 'rubocop-rspec', '~> 1.36.0'

  gem 'simplecov', '~> 0.17'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
