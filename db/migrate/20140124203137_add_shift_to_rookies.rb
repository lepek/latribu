class AddShiftToRookies < ActiveRecord::Migration
  def change
    add_reference :rookies, :shift, index: true
  end
end
