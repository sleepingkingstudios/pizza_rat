# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

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
  attribute :source_url,         :string, default: ''

  ### Validations
  validates :application_status,
    inclusion: { allow_nil: true, in: ApplicationStatuses.all.values },
    presence:  true
  validates :company_name, presence: true
  validates :source,       presence: true
  validates :time_period,
    format:   {
      message: 'must be in YYYY-MM format',
      with:    TIME_PERIOD_FORMAT
    },
    presence: true
  validates :time_period_month,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    12,
      only_integer:             true,
      unless:                   -> { errors.key?(:time_period) }
    }
  validates :time_period_year,
    numericality: {
      greater_than: 2009,
      less_than:    2030,
      only_integer: true,
      unless:       -> { errors.key?(:time_period) }
    }

  def time_period_month
    time_period&.split('-')&.last
  end

  def time_period_year
    time_period&.split('-')&.first
  end
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
#  notes              :text             default(""), not null
#  source             :string           not null
#  source_data        :jsonb            not null
#  time_period        :string           not null
#  title              :string           default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_jobs_on_action_required_and_company_name     (action_required,company_name)
#  index_jobs_on_application_status_and_company_name  (application_status,company_name)
#  index_jobs_on_company_name                         (company_name)
#
