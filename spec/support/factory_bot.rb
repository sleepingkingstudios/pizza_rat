# frozen_string_literal: true

require 'factory_bot_rails'

FactoryBot.definition_file_paths = [File.join('spec', 'support', 'factories')]

FactoryBot.find_definitions
