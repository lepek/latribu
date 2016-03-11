class AddUniqueIndexToInscriptions < ActiveRecord::Migration
  def change
    add_index(:inscriptions, [:user_id, :shift_date], unique: true)
  end
end
