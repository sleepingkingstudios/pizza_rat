# frozen_string_literal: true

class CreateTimePeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :time_periods do |t|
      t.integer :month, null: false
      t.integer :year,  null: false

      t.timestamps
    end

    add_index :time_periods, %i[year month], unique: true
  end
end
