class AddCancelInscriptionToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :cancel_inscription, :integer, :default => 2
  end
end
