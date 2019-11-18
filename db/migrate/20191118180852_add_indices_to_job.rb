# frozen_string_literal: true

class AddIndicesToJob < ActiveRecord::Migration[6.0]
  def change
    add_index :jobs, %i[action_required company_name]
    add_index :jobs, %i[application_status company_name]
    add_index :jobs, :company_name
  end
end
