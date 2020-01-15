# frozen_string_literal: true

FactoryBot.define do
  # :nocov:
  factory :manufacturer, class: 'Spec::Manufacturer' do
    sequence(:name) { |index| "Company #{index}" }

    founded_at { 1.year.ago }
  end
  # :nocov:
end
