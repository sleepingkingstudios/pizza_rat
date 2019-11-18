# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.boolean :action_required,    null: false, default: true
      t.boolean :application_active, null: false, default: true
      t.string  :application_status, null: false
      t.string  :company_name,       null: false
      t.jsonb   :data,               null: false, default: {}
      t.text    :notes,              null: false, default: ''
      t.string  :source,             null: false
      t.jsonb   :source_data,        null: false, default: {}
      t.string  :time_period,        null: false
      t.string  :title,              null: false, default: ''

      t.timestamps
    end
  end
end
