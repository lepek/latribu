class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.string :day
      t.time :start_time
      t.time :end_time
      t.integer :open_inscription
      t.integer :close_inscription
      t.integer :max_attendants
      t.timestamps
    end
  end
end
