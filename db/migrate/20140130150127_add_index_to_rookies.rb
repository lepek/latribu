class AddIndexToRookies < ActiveRecord::Migration
  def change
    add_index :rookies, :shift_date
  end
end
