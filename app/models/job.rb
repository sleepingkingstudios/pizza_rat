# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

require 'operations/records/factory'

# A Job represents a job listing from a company and the corresponding
# application, if any. It tracks the status of the application from Prospect
# through Applied and Interviewing (if applicable) and finally to Closed.
class Job < ApplicationRecord
  ApplicationStatuses = SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
    APPLIED:      'applied',
    CLOSED:       'closed',
    INTERVIEWING: 'interviewing',
    PROSPECT:     'prospect'
  ).freeze

  JobTypes = SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
    CONTRACT:  'contract',
    FULL_TIME: 'full_time',
    PART_TIME: 'part_time'
  ).freeze

  Factory = Operations::Records::Factory.new(self)

  TIME_PERIOD_FORMAT = /\A\d{4}-\d{2}\z/.freeze
  private_constant :TIME_PERIOD_FORMAT

  scope :applied,
    -> { where(application_status: ApplicationStatuses::APPLIED) }

  scope :closed,
    -> { where(application_status: ApplicationStatuses::CLOSED) }

  scope :interviewing,
    -> { where(application_status: ApplicationStatuses::INTERVIEWING) }

  scope :prospects,
    -> { where(application_status: ApplicationStatuses::PROSPECT) }

  ### Attributes
  attribute :application_status, :string, default: ApplicationStatuses::PROSPECT
  attribute :company_name,       :string, default: ''

  ### Associations
  belongs_to :time_period

  ### Validations
  validates :application_status,
    inclusion: { allow_nil: true, in: ApplicationStatuses.all.values },
    presence:  true
  validates :job_type,
    inclusion: { allow_nil: true, in: JobTypes.all.values },
    presence:  true
  validates :company_name, presence: true
  validates :source,       presence: true
end

# == Schema Information
#
# Table name: jobs
#
#  id                 :bigint           not null, primary key
#  action_required    :boolean          default(TRUE), not null
#  application_active :boolean          default(TRUE), not null
#  application_status :string           not null
#  company_name       :string           not null
#  data               :jsonb            not null
#  job_type           :string           default(""), not null
#  notes              :text             default(""), not null
#  recruiter_agency   :string           default(""), not null
#  recruiter_name     :string           default(""), not null
#  source             :string           not null
#  source_data        :jsonb            not null
#  title              :string           default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  time_period_id     :bigint
#
# Indexes
#
#  index_jobs_on_action_required_and_company_name     (action_required,company_name)
#  index_jobs_on_application_status_and_company_name  (application_status,company_name)
#  index_jobs_on_company_name                         (company_name)
#  index_jobs_on_time_period_id                       (time_period_id)
#
# Foreign Keys
#
#  fk_rails_...  (time_period_id => time_periods.id)
#
