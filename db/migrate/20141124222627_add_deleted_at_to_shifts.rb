class AddDeletedAtToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :deleted_at, :datetime
  end
end
