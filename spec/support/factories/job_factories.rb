# frozen_string_literal: true

FactoryBot.define do
  # :nocov:
  factory :job, class: 'Job' do
    sequence(:company_name) { |index| "Company #{index}" }

    job_type    { Job::JobTypes::FULL_TIME }
    source      { 'Internet' }
    source_data { { 'url' => 'https://www.example.com' } }
    time_period { nil }

    trait :accepted do
      application_status { Job::ApplicationStatuses::CLOSED }

      data do
        {
          'events' => [
            { 'type' => 'viewed_listing' },
            { 'type' => 'application_sent' },
            { 'type' => 'interview_scheduled' },
            { 'type' => 'interview_completed' },
            { 'type' => 'offer_made' },
            { 'type' => 'offer_accepted' }
          ]
        }
      end
    end

    trait :applied do
      application_status { Job::ApplicationStatuses::APPLIED }

      data do
        {
          'events' => [
            { 'type' => 'viewed_listing' },
            { 'type' => 'application_sent' }
          ]
        }
      end
    end

    trait :closed do
      application_status { Job::ApplicationStatuses::CLOSED }

      data do
        {
          'events' => [
            { 'type' => 'viewed_listing' },
            { 'type' => 'application_sent' },
            { 'type' => 'process_expired' }
          ]
        }
      end
    end

    trait :contract do
      job_type { Job::JobTypes::CONTRACT }
    end

    trait :interviewing do
      application_status { Job::ApplicationStatuses::INTERVIEWING }

      data do
        {
          'events' => [
            { 'type' => 'viewed_listing' },
            { 'type' => 'application_sent' },
            { 'type' => 'interview_scheduled' }
          ]
        }
      end
    end

    trait :prospect do
      application_status { Job::ApplicationStatuses::PROSPECT }

      data do
        {
          'events' => [{ 'type' => 'viewed_listing' }]
        }
      end
    end

    trait :rejected do
      application_status { Job::ApplicationStatuses::CLOSED }

      data do
        {
          'events' => [
            { 'type' => 'viewed_listing' },
            { 'type' => 'application_sent' },
            { 'type' => 'interview_scheduled' },
            { 'type' => 'interview_completed' },
            { 'type' => 'rejected' }
          ]
        }
      end
    end

    trait :with_recruiter do
      recruiter_agency { 'Recruiter Agency 0' }
      recruiter_name   { 'Recruiter 0' }
    end

    trait :with_time_period do
      time_period { create(:time_period) }
    end
  end
  # :nocov:
end
