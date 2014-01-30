class AddIndexToInscriptions < ActiveRecord::Migration
  def change
    add_index :inscriptions, :shift_date
  end
end
