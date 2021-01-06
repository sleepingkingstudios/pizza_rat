# frozen_string_literal: true

class AddRecruiterToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :job_type,         :string, null: false, default: ''
    add_column :jobs, :recruiter_agency, :string, null: false, default: ''
    add_column :jobs, :recruiter_name,   :string, null: false, default: ''
  end
end
