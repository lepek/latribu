class AddAttendedToRookies < ActiveRecord::Migration
  def change
    add_column :rookies, :attended, :boolean, :default => false
  end
end
