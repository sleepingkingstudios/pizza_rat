# frozen_string_literal: true

FactoryBot.define do
  # :nocov:
  factory :time_period, class: 'TimePeriod' do
    sequence(:year, 1000)

    month { rand(1..12) }
  end
  # :nocov:
end
