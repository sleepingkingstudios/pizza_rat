# frozen_string_literal: true

class AddTimePeriodIdToJobs < ActiveRecord::Migration[6.0]
  def change
    remove_column :jobs, :time_period, :string

    add_reference :jobs, :time_period, foreign_key: true
  end
end
