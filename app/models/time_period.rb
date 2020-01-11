# frozen_string_literal: true

require 'operations/records/factory'

# A TimePeriod represents a discrete search interval, starting with the given
# month and year.
class TimePeriod < ApplicationRecord
  Factory = Operations::Records::Factory.new(self)

  def self.active
    order(year: :desc, month: :desc).limit(1).first
  end

  ### Validations
  validates :month,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    12,
      only_integer:             true,
      unless:                   ->(record) { record.month.blank? }
    },
    presence:     true,
    uniqueness:   { scope: :year }

  validates :year,
    numericality: {
      greater_than_or_equal_to: 1,
      only_integer:             true,
      unless:                   ->(record) { record.year.blank? }
    },
    presence:     true
end

# == Schema Information
#
# Table name: time_periods
#
#  id         :bigint           not null, primary key
#  month      :integer          not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_time_periods_on_year_and_month  (year,month) UNIQUE
#
