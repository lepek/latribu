class AddCompositeIndexToInscriptions < ActiveRecord::Migration
  def change
    add_index(:inscriptions, [:shift_id, :shift_date])
    add_index(:rookies, [:shift_id, :shift_date])
  end
end
