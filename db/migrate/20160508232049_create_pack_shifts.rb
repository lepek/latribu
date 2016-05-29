class CreatePackShifts < ActiveRecord::Migration
  def change
    create_table :pack_shifts do |t|
      t.integer :shift_id, index: true
      t.integer :pack_id, index: true
    end
  end
end
