class AddAttendToInscriptions < ActiveRecord::Migration
  def change
    add_column :inscriptions, :attended, :boolean, :default => false

  end
end
